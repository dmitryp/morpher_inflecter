# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper.rb'

describe MorpherInflecter do
  before(:all) do

    @singular_noun_answer = '{
  "Р": "рубина",
  "Д": "рубину",
  "В": "рубин",
  "Т": "рубином",
  "П": "рубине",
  "множественное": {
    "И": "рубины",
    "Р": "рубинов",
    "Д": "рубинам",
    "В": "рубины",
    "Т": "рубинами",
    "П": "рубинах"
  }
}'

    @singular_noun_inflection = {
      singular: ["рубин", "рубина", "рубину", "рубин", "рубином", "рубине"],
      plural: ["рубины", "рубинов", "рубинам", "рубины", "рубинами", "рубинах"]
    }

    @plural_noun_answer = '{
  "Р": "рубинов",
  "Д": "рубинам",
  "В": "рубины",
  "Т": "рубинами",
  "П": "рубинах"
}
'
    @plural_noun_inflection = { plural: ["рубины", "рубинов", "рубинам", "рубины", "рубинами", "рубинах"] }

    @error = { error: "496", code: "5", message: "Не найдено русских слов." }


  end

  before(:each) do
    @inflection = MorpherInflecter::Inflection.new
    MorpherInflecter::clear_cache
  end

  it "should return an hash of inflections for singular noun" do
    @inflection.stub_chain(:open, :read).and_return(@singular_noun_answer)
    MorpherInflecter::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflecter.inflections("рубин").should == @singular_noun_inflection
  end

  it "should return an hash of inflections for plural noun" do
    @inflection.stub_chain(:open, :read).and_return(@plural_noun_answer)
    MorpherInflecter::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflecter.inflections("рубины").should == @plural_noun_inflection
  end

  it "should return error when webservice returns error" do
    exception_io = mock('io')
    exception_io.stub_chain(:status,:[],:message)
    @inflection.stub(:open).and_raise(OpenURI::HTTPError.new('496',exception_io))
    MorpherInflecter::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflecter.inflections("рубин1").should == @error
  end

  it "should return nil when webservice does not return xml or connection failed" do
    exception_io = mock('io')
    exception_io.stub_chain(:status,:[],:message)
    @inflection.stub(:open).and_raise(OpenURI::HTTPError.new('502',exception_io))

    MorpherInflecter::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflecter.inflections("рубин").should == {error: '502'}
  end

  context 'Cache' do
    it "should cache successful lookups" do
      @inflection.stub!(:get).and_return(parsed_json(@singular_noun_answer))
      MorpherInflecter::Inflection.should_receive(:new).once.and_return(@inflection)

      2.times { MorpherInflecter.inflections("рубин") }
    end

    it "should NOT cache unsuccessful lookups" do
      @inflection.stub!(:get).and_return({error: "496"})
      MorpherInflecter::Inflection.should_receive(:new).twice.and_return(@inflection)

      2.times { MorpherInflecter.inflections("рубин") }
    end

    it "should NOT cache unsuccessful lookups" do
      sample = parsed_json(@singular_noun_answer)
      @inflection.stub!(:get).and_return(sample)
      MorpherInflecter::Inflection.should_receive(:new).once.and_return(@inflection)

      2.times { MorpherInflecter.inflections("рубин") }
    end

    it "should allow to clear cache" do
      sample = parsed_json(@singular_noun_answer)
      @inflection.stub!(:get).and_return(sample)
      MorpherInflecter::Inflection.should_receive(:new).twice.and_return(@inflection)

      MorpherInflecter.inflections("рубин")
      MorpherInflecter.clear_cache
      MorpherInflecter.inflections("рубин")
    end
  end
end
