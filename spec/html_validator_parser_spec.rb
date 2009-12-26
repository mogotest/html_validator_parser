require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HTML Validator Parser" do

  before(:each) do
    @parser = HtmlValidatorParser.new
    @parser.parse(error_and_warnings_results)
    @uri = 'http://www.google.com/'
  end

  it "should return validation errors" do
    @parser[@uri][:errors].size.should == 65

    error = @parser[@uri][:errors].first
    error[:line].should == '1'
    error[:column].should == '14'
    error[:message].should == 'no internal or external document type declaration subset; will parse without validation'
  end

  it 'should return validation errors by line number' do
    @parser[@uri][1][:errors].size.should == 7 # There should be seven errors for the first line.

    error = @parser[@uri][1][:errors].first
    error[:line].should == '1'
    error[:column].should == '14'
    error[:message].should == 'no internal or external document type declaration subset; will parse without validation'
  end

  it "should return validation warnings" do
    @parser[@uri][:warnings].size.should == 19

    warning = @parser[@uri][:warnings].first
    warning[:line].should == '1'
    warning[:column].should == '461'
    warning[:message].should == 'cannot generate system identifier for general entity "ct"'
  end

  it 'should return validation warnings by line number' do
    @parser[@uri][1][:warnings].size.should == 3 # There should be three warnings for the first line.

    warning = @parser[@uri][1][:warnings].first
    warning[:line].should == '1'
    warning[:column].should == '461'
    warning[:message].should == 'cannot generate system identifier for general entity "ct"'
  end

  it "should only only contain one URI" do
    @parser.keys.size.should == 1
  end

  private

  def error_and_warnings_results
    File.open(File.expand_path(File.dirname(__FILE__) + '/fixtures/errors_and_warnings.xml')).read
  end

end