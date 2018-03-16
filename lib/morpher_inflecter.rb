# -*- encoding: utf-8 -*-

require "morpher_inflecter/version"
require 'rubygems'
require 'open-uri'
require 'json'

module MorpherInflecter
  URL = 'https://ws3.morpher.ru/russian/declension'.freeze

  # Падежи
  CASES = %w(И Р Д В Т П)

  ERROR_CODES = {
     "1"  => ["402", "Превышен лимит на количество запросов в сутки. Перейдите на следующий тарифный план."],
     "3"  => ["403", "IP заблокирован."],
     "4"  => ["495", "Склонение числительных в declension не поддерживается. Используйте метод spell."],
     "5"  => ["496", "Не найдено русских слов."],
     "6"  => ["400", "Не указан обязательный параметр s."],
     "7"  => ["402", "Необходимо оплатить услугу."],
     "9"  => ["498", "Данный token не найден."],
     "10" => ["497", "Неверный формат токена."],
     "11" => ["500", "Ошибка сервера."],
     "12" => ["494", "Указаны неправильные флаги."]
  }

  # Класс для получения данных с веб-сервиса Морфера.
  class Inflection
    def get(text, token = nil)
      params = { s: text }
      params[:token] = token if token

      uri = URI(MorpherInflecter::URL)
      uri.query = URI.encode_www_form(params)

      JSON.parse( open(uri, 'Accept' => 'application/json').read )

    rescue OpenURI::HTTPError => ex
      error = { error: ex.message.strip }
      if MorpherInflecter::ERROR_CODES.map{|c| c[1][0]}.include?(error[:error])
        error.update JSON.parse(ex.io.string)
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
