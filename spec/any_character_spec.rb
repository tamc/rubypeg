# encoding: utf-8
$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'rubypeg'

class AnyCharacter < RubyPeg
  def root
    node :root do 
      any_character
    end
  end  
end

describe AnyCharacter do
  
  it "matches one of any character" do
    AnyCharacter.parse("abcd").to_ast.should == [:root,'a']
  end
  
  it "doesn't match no character" do
    AnyCharacter.parse("").should == nil
  end
  
  it "should work with Chinese characters" do
    AnyCharacter.parse("结果").to_ast.should == [:root,'结']
  end
    
end
