# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper.rb'

describe MorpherInflecter do
  before(:all) do
    @singular_noun_answer = <<EOS
<?xml version="1.0" encoding="utf-8"?>
<xml xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://morpher.ru/">
  <Р>рубина</Р>
  <Д>рубину</Д>
  <В>рубин</В>
  <Т>рубином</Т>
  <П>рубине</П>
  <множественное>
    <И>рубины</И>
    <Р>рубинов</Р>
    <Д>рубинам</Д>
    <В>рубины</В>
    <Т>рубинами</Т>
    <П>рубинах</П>
  </множественное>
</xml>
EOS
    @singular_noun_inflection = {:singular=>["рубин", "рубина", "рубину", "рубин", "рубином", "рубине"], :plural=>["рубины", "рубинов", "рубинам", "рубины", "рубинами", "рубинах"]}

    @plural_noun_answer = <<EOS
<?xml version="1.0" encoding="utf-8"?>
<xml xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://morpher.ru/">
  <Р>рубинов</Р>
  <Д>рубинам</Д>
  <В>рубины</В>
  <Т>рубинами</Т>
  <П>рубинах</П>
</xml>
EOS
    @plural_noun_inflection = {:plural=>["рубины", "рубинов", "рубинам", "рубины", "рубинами", "рубинах"]}

    @error_answer =<<EOS
<error>
  <code>5</code>
  <message>Не найдено русских слов.</message>
</error>
EOS
    @error_code = {:error => 5}
  end

  before(:each) do
    @inflection = mock(:inflection)
    MorpherInflecter::clear_cache
  end

  it "should return an hash of inflections for singular noun" do
    @inflection.stub!(:get).and_return(parsed_xml(@singular_noun_answer))
    MorpherInflecter::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflecter.inflections("рубин").should == @singular_noun_inflection
  end

  it "should return an hash of inflections for plural noun" do
    @inflection.stub!(:get).and_return(parsed_xml(@plural_noun_answer))
    MorpherInflecter::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflecter.inflections("рубины").should == @plural_noun_inflection
  end

  it "should return error when webservice returns error" do
    @inflection.stub!(:get).and_return(parsed_xml(@error_answer))
    MorpherInflecter::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflecter.inflections("рубин1").should == {:error => 5}
  end

  it "should return nil when webservice does not return xml or connection failed" do
    @inflection.stub!(:get).and_return(nil)
    MorpherInflecter::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflecter.inflections("рубин").should == nil
  end

  context 'Cache' do
    it "should cache successful lookups" do
      @inflection.stub!(:get).and_return(parsed_xml(@singular_noun_answer))
      MorpherInflecter::Inflection.should_receive(:new).once.and_return(@inflection)

      2.times { MorpherInflecter.inflections("рубин") }
    end

    it "should NOT cache unseccussful lookups" do
      sample = nil
      @inflection.stub!(:get).and_return(sample)
      MorpherInflecter::Inflection.should_receive(:new).twice.and_return(@inflection)

      2.times { MorpherInflecter.inflections("рубин") }
    end

    it "should NOT cache unseccussful lookups" do
      sample = parsed_xml(@singular_noun_answer)
      @inflection.stub!(:get).and_return(sample)
     MorpherInflecter::Inflection.should_receive(:new).once.and_return(@inflection)

      2.times { MorpherInflecter.inflections("рубин") }
    end

    it "should allow to clear cache" do
      sample = parsed_xml(@singular_noun_answer)
      @inflection.stub!(:get).and_return(sample)
      MorpherInflecter::Inflection.should_receive(:new).twice.and_return(@inflection)

      MorpherInflecter.inflections("рубин")
      MorpherInflecter.clear_cache
      MorpherInflecter.inflections("рубин")
    end
  end
end
