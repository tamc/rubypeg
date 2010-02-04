$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'ruby_peg'

class SimpleSequence < RubyPeg
  def root
    node :root do 
      terminal('x') && terminal('y') && terminal('z')
    end
  end  
end

describe SimpleSequence do
  
  it "matches the sequence" do
    SimpleSequence.parse("xyz").to_ast.should == [:root,'x','y','z']
  end
  
  it "doesn't matches anything else" do
    SimpleSequence.parse("xy.").should == nil
  end
  
end

class RepeatedSequence < RubyPeg
  def root
    node :root do 
      any_number_of { terminal('1') && ignore { terminal('2') } && terminal('3') } &&  one_or_more { terminal('x') && terminal('y') && terminal('z') } && terminal('z')
    end
  end  
end

describe RepeatedSequence do
  
  it "matches the sequence" do
    RepeatedSequence.parse("xyzz").to_ast.should == [:root,'x','y','z','z']
  end
  
  it "matches a repeated sequence" do
    RepeatedSequence.parse("xyzxyzz").to_ast.should == [:root,'x','y','z','x','y','z','z']
  end
  
  it "matches an optional repeated sequence" do
    RepeatedSequence.parse("123123xyzxyzz").to_ast.should == [:root,'1','3','1','3','x','y','z','x','y','z','z']
  end
  
  it "doesn't matches anything else" do
    RepeatedSequence.parse("xyxy.").should == nil
  end
  
end