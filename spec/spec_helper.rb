require 'rspec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'morpher_inflecter'

def parsed_xml(text)
  Nokogiri::XML.parse(text)
end
