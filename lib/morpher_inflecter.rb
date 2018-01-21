# -*- encoding: utf-8 -*-

require "morpher_inflecter/version"
require 'rubygems'
require 'open-uri'
require 'json'

module MorpherInflecter
  # Падежи
  CASES = %w(И Р Д В Т П)

  ERROR_CODES = {
    "402" => ["1", "Превышен лимит на количество запросов в сутки. Перейдите на следующий тарифный план."],
    "403" => ["3", "IP заблокирован."],
    "495" => ["4", "Склонение числительных в declension не поддерживается. Используйте метод spell."],
    "496" => ["5", "Не найдено русских слов."],
    "400" => ["6", "Не указан обязательный параметр s."],
    "402" => ["7", "Необходимо оплатить услугу."],
    "498" => ["9", "Данный token не найден."],
    "497" => ["10", "Неверный формат токена."],
    "500" => ["11", "Ошибка сервера."],
    "494" => ["12", "Указаны неправильные флаги."]
  }

  # Класс для получения данных с веб-сервиса Морфера.
  class Inflection
    def get(text, token = nil)
      params = { s: text }
      params[:token] = token if token

      uri = URI('https://ws3.morpher.ru/russian/declensionw')
      uri.query = URI.encode_www_form(params)

      JSON.parse( open(uri, 'Accept' => 'application/json').read )

    rescue OpenURI::HTTPError => ex
      error = { error: ex.message.strip }
      if code = MorpherInflecter::ERROR_CODES[ex.message.strip]
        error.merge!(code: code[0], message: code[1])
      end
      error
    end
  end

  # Кеширование успешных результатов запроса к веб-сервису
  @@cache = {}

  # Возвращает хэш склонений в следуюшем формате
  # {:singular => [], :plural => []}
  # Если слово не найдено в словаре или произошла ошибка, будет возвращен код ошибки { error: "XXX", code: "Y", message: 'error message' }
  def self.inflections(word, options = {})

    lookup = cache_lookup(word)
    return lookup if lookup
    resp = Inflection.new.get(word, options[:token])
    inflections = {}

    if resp[:error]
      inflections = resp
    else
      plural_only = resp['множественное'].nil?

      inflections[:singular] = [] unless plural_only
      inflections[:plural] = []

      CASES.each do |_case|
        i = _case == 'И' ? word : resp[_case]

        if plural_only
          inflections[:plural] << i
        else
          inflections[:singular] << i
          inflections[:plural] << resp['множественное'][_case]
        end
      end

      cache_store(word, inflections)
    end

    inflections
  end

  # Очистить кеш
  def self.clear_cache
    @@cache.clear
  end

  private
    def self.cache_lookup(word)
      @@cache[word.to_s]
    end

    def self.cache_store(word, value)
      @@cache[word.to_s] = value
    end
end
