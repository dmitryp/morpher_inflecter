# -*- encoding: utf-8 -*-

require "morpher_inflecter/version"
require 'rubygems'
require 'open-uri'
require 'nokogiri'

module MorpherInflecter
  # Падежи
  CASES = %w(И Р Д В Т П)

  # Класс для получения данных с веб-сервиса Морфера.
  class Inflection
    def get(text, login = nil, password = nil)
      url = 'http://morpher.ru/WebService.asmx/GetXml?'
      options = { :s => text }
      if login and password
        options[:username] = login
        options[:password] = password
      end
      url = url + URI.encode(options.map{|key, val| "#{key}=#{val}"}.join('&'))
      Nokogiri.XML(open(url)) rescue nil
    end
  end

  # Кеширование успешных результатов запроса к веб-сервису
  @@cache = {}

  # Возвращает хэш склонений в следуюшем формате
  # {:singular => [], :plural => []}
  # Если слово не найдено в словаре или произошла ошибка, будет возвращен код ошибки {:error => XXX}
  def self.inflections(word)
    inflections = {}

    lookup = cache_lookup(word)
    return lookup if lookup

    doc = Inflection.new.get(word)

    return nil if doc.nil?

    unless doc.xpath('error/code').empty?
      inflections[:error] = doc.xpath('error/code').text.to_i
    else
      singular = true unless doc.search('множественное').empty?

      CASES.each do |_case|
        nodes = doc.search(_case)
        if singular == true
          s = _case == 'И' ? word : nodes.first.text.to_s
          p = nodes.last.text.to_s
        else
          p = _case == 'И' ? word : nodes.last.text.to_s
        end

        (inflections[:singular]||=[]) << s if singular
        (inflections[:plural]||=[])  << p if p
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
