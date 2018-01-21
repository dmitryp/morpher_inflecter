require 'rspec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'morpher_inflecter'

def parsed_json(text)
  JSON.parse(text)
end
