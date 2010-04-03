$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'ruby_peg'

class TerminalNodeTest < RubyPeg
  def root
    terminal "one"
  end
end

describe TerminalNodeTest do
  
  def parse(text)
    TerminalNodeTest.parse(text)
  end
  
  it "terminals are, by default, Strings" do
    parse("one").should == "one"
  end
  
  it "they have been, by default, extended with the module TerminalNode" do
    parse("one").should be_kind_of(TerminalNode)    
  end
  
  it "TerminalNode responds to to_ast by returning itself" do
    parse("one").to_ast.should be_kind_of(String)
    parse("one").to_ast.should == "one"
  end
  
  it "TerminalNode responds to visit(builder) by returning itself" do
    class TestBuilder; end
    parse("one").visit(TestBuilder.new).should be_kind_of(String)
    parse("one").visit(TestBuilder.new).should == "one"
  end
  
end

class CreateTerminalNodeTest < RubyPeg
  def root
    terminal "one"
  end
  
  def create_terminal_node(string)
    /#{string}/
  end
end

describe CreateTerminalNodeTest do
  
  def parse(text)
    CreateTerminalNodeTest.parse(text)
  end
  
  it "the class of the terminal can be altered by overriding the create_terminal_node(string) method" do
    parse("one").should be_kind_of(Regexp)
  end
    
end

class StringTerminalTest < RubyPeg
  def root
    terminal "one"
  end
end

describe StringTerminalTest do
  
  def parse(text)
    StringTerminalTest.parse(text)
  end
  
  it "if given a string, matches that string but nothing else" do
    parse("one").to_ast.should == 'one'
    parse("two").should == nil
    parse("onetwo").to_ast.should == 'one'
  end
    
end

class RegexpTerminalTest < RubyPeg
  def root
    terminal /one|Two/i
  end
end

describe RegexpTerminalTest do
  
  def parse(text)
    RegexpTerminalTest.parse(text)
  end
  
  it "if given a regular expression, matches that expression but nothing else" do
    parse("one").to_ast.should == 'one'
    parse("two").to_ast.should == 'two'
    parse("onetwo").to_ast.should == 'one'
    parse("three").should == nil
  end
    
end

class AnythingTerminalTest < RubyPeg
  def root
    terminal 1.0
  end
end

describe AnythingTerminalTest do
  
  def parse(text)
    AnythingTerminalTest.parse(text)
  end
  
  it "if given anything else, converts it to astring and tries to match that" do
    parse("1.0").to_ast.should == '1.0'
    parse("1").should == nil
    parse("1.011").to_ast.should == '1.0'
  end
    
end