$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'rubypeg'

class OneOrMore < RubyPeg
  def root
    node :root do 
      one_or_more { terminal('x') }
    end
  end  
end

describe OneOrMore do
  
  it "matches one" do
    OneOrMore.parse("x.").to_ast.should == [:root,'x']
  end
  
  it "matches more than one" do
    OneOrMore.parse("xx.").to_ast.should == [:root,'x','x']
  end
  
  it "doesn't match none" do
    OneOrMore.parse(".").should == nil
  end
  
end

class ZeroOrMore < RubyPeg
  def root
    node :root do 
      any_number_of { terminal('x') }
    end
  end  
end

describe ZeroOrMore do
  
  it "matches one" do
    ZeroOrMore.parse("x.").to_ast.should == [:root,'x']
  end
  
  it "matches more than one" do
    ZeroOrMore.parse("xx.").to_ast.should == [:root,'x','x']
  end
  
  it "matches none" do
    ZeroOrMore.parse(".").to_ast.should == [:root]
  end
  
end

class ZeroOrOne < RubyPeg
  def root
    node :root do 
      optional { terminal('x') }
    end
  end  
end

describe ZeroOrOne do
  
  it "matches one" do
    ZeroOrOne.parse("x.").to_ast.should == [:root,'x']
  end
  
  it "doesn't match more than one" do
    ZeroOrOne.parse("xx.").to_ast.should == [:root,'x']
  end
  
  it "matches none" do
    ZeroOrOne.parse(".").to_ast.should == [:root]
  end
  
end