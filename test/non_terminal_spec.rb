$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'ruby_peg'

class NonTerminalNodeTest < RubyPeg
  def root
    node :one do
      terminal("one")
    end
  end
end

class ChildlessNonTerminalNodeTest < RubyPeg
  def root
    node :one do
      ignore { terminal("one") }
    end
  end
end

class MultipleChildNonTerminalNodeTest < RubyPeg
  def root
    node :one do 
      terminal("one") && terminal("two")
    end
  end
end

class CreateNonTerminalNodeTest < NonTerminalNodeTest
  
  def create_non_terminal_node(type,children)
    [type,*children.map(&:to_s)]
  end
end

describe NonTerminalNodeTest do
  
  def parse(text)
    NonTerminalNodeTest.parse(text)
  end
  
  it "non terminals are only created if the terminals that they contain match" do
    parse("two").should == nil
  end
  
  it "non terminals are, by default, instances of NonTerminalNode" do
    parse("one").should be_kind_of(NonTerminalNode)
  end
  
  it "these have a type attribute that returns the symbol used as an argument to the node call" do
    parse("one").type.should == :one
  end  
  
  it "these have a children attribute that contains an array of child nodes to this one" do
    parse("one").children.should be_kind_of(Array)
    parse("one").children.first.should be_kind_of(TerminalNode)
    parse("one").children.first.to_s.should == "one"
  end  

  it "if there are no children, this returns an empty array" do
    ChildlessNonTerminalNodeTest.parse("one").children.should == []
  end
  
  it "TerminalNode responds to to_ast by returning [:type,*children]" do
    parse("one").to_ast.should be_kind_of(Array)
    parse("one").to_ast.should == [:one,"one"]
    MultipleChildNonTerminalNodeTest.parse("onetwo").to_ast.should == [:one,"one","two"]
  end
  
  it "TerminalNode responds to to_ast by returning [:type] if there are no children" do
    ChildlessNonTerminalNodeTest.parse("one").to_ast.should be_kind_of(Array)
    ChildlessNonTerminalNodeTest.parse("one").to_ast.should == [:one]
  end
  
  it "TerminalNode responds to build(builder) by trying to call a method with the same name on the builder and with its children as arguments" do
    builder = mock(:TestBuilder)
    builder.should_receive(:one).with {|a| a.kind_of?(TerminalNode) && a.to_s == "one"}.and_return(1)
    parse("one").build(builder).should == 1
  end
  
  it "If the builder doesn't have a method with its name, then it calls build(builder) on its children, returning a string if there is only one child" do
    builder = mock(:TestBuilder)
    parse("one").build(builder).should == "one"
  end
  
  it "If the builder doesn't have a method with its name, then it calls build(builder) on its children, returning a an array of strings if there is more than one child" do
    builder = mock(:TestBuilder)
    MultipleChildNonTerminalNodeTest.parse("onetwo").build(builder).should == ["one","two"]
  end
  
  it "the class of the non terminal can be altered by overriding the create_non_terminal_node(type,children) method" do
    result = CreateNonTerminalNodeTest.parse("one")
    result.should be_kind_of(Array)
    result.first.should == :one
    result.last.should == "one"
  end
  
  
  
end