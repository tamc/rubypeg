$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'rubypeg'

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

# class CustomNode
#   def initialize(children)
#     # ignored
#   end
# end
# 
# class CustomNodeClassNonTerminalNodeTest < RubyPeg
#   def root
#     node CustomNode do
#       terminal("one")
#     end
#   end 
# end
# 
# module CustomNodeA; end
# module CustomNodeB; end
# 
# class CustomNodeModuleNonTerminalNodeTest < RubyPeg
#   def root
#     node CustomNodeA, CustomNodeB do
#       terminal("one")
#     end
#   end
# end

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
  
  it "if a symbol is passed to the node method then non terminals are, by default, instances of Array that have been extended with a NonTerminalNode moduoe" do
    parse("one").class.should == Array
    parse("one").should be_kind_of(NonTerminalNode)
  end
  
  it "NonTerminalNode instances have a type attribute that returns the symbol used as an argument to the node call" do
    parse("one").type.should == :one
  end  
  
  it "NonTerminalNode instances are an array of child nodes" do
    parse("one").should be_kind_of(Array)
    parse("one").first.should be_kind_of(TerminalNode)
    parse("one").first.to_s.should == "one"
  end  

  it "if there are no children, it is an empty array" do
    ChildlessNonTerminalNodeTest.parse("one").should == []
  end
  
  it "NonTerminalNode instances respond to to_ast by returning [:type,*children]" do
    parse("one").to_ast.should be_kind_of(Array)
    parse("one").to_ast.should == [:one,"one"]
    MultipleChildNonTerminalNodeTest.parse("onetwo").to_ast.should == [:one,"one","two"]
  end
  
  it "NonTerminalNode instances respond to to_ast by returning [:type] if there are no children" do
    ChildlessNonTerminalNodeTest.parse("one").to_ast.should be_kind_of(Array)
    ChildlessNonTerminalNodeTest.parse("one").to_ast.should == [:one]
  end
  
  it "NonTerminalNode instances respond to visit(builder) by trying to call a method with the same name on the builder and with its children as arguments" do
    builder = mock(:TestBuilder)
    builder.should_receive(:one).with {|a| a.kind_of?(TerminalNode) && a.to_s == "one"}.and_return(1)
    parse("one").visit(builder).should == 1
  end
  
  it "If the builder doesn't have a method with its name, then it calls visit(builder) on its children, returning a string if there is only one child" do
    builder = mock(:TestBuilder)
    parse("one").visit(builder).should == "one"
  end
  
  it "If the builder doesn't have a method with its name, then it calls visit(builder) on its children, returning a an array of strings if there is more than one child" do
    builder = mock(:TestBuilder)
    MultipleChildNonTerminalNodeTest.parse("onetwo").visit(builder).should == ["one","two"]
  end
  
  it "the class of the non terminal can be altered by overriding the create_non_terminal_node(type,children) method" do
    result = CreateNonTerminalNodeTest.parse("one")
    result.should be_kind_of(Array)
    result.first.should == :one
    result.last.should == "one"
  end
  
  # it "if a class is passed to the node method then a class of that type is created as the non-terminal. Its initializer must take an array of children as its argument" do
  #   CustomNodeClassNonTerminalNodeTest.parse("one").class.should == CustomNode
  # end
  # 
  # it "if one or more modules are passed to the node method then they are used to extend the non-terminal array" do
  #   CustomNodeModuleNonTerminalNodeTest.parse("one").should be_kind_of(Array)
  #   CustomNodeModuleNonTerminalNodeTest.parse("one").should be_kind_of(CustomNodeA)
  #   CustomNodeModuleNonTerminalNodeTest.parse("one").should be_kind_of(CustomNodeB)
  # end
  
end

class BasketPeg < RubyPeg
  def root
    node :basket do
      one_or_more { items }
    end
  end
  
  def items
    node :item do
      number && optional_space && fruit && optional_space
    end
  end
  
  def number
    terminal(/\d+/)
  end

  def fruit
    node :fruit do
      (terminal("apple") || terminal("pear")) && ignore{ optional{ terminal("s") } }
    end
  end
  
  def optional_space
    ignore{ optional{ terminal(" ") }}
  end
end

describe BasketPeg do
  
  it "Illustrates NonTerminalNode" do
    BasketPeg.parse("1 apple 2 apples 3 pears").should be_kind_of(NonTerminalNode)
  end
  
  it "Illustrates NonTerminalNode#type" do
    BasketPeg.parse("1 apple 2 apples 3 pears").type.should == :basket
  end
  
  it "Illustrates NonTerminalNode#to_ast" do
    BasketPeg.parse("1 apple 2 apples 3 pears").to_ast.should == [:basket, [:item, "1", [:fruit, "apple"]], [:item, "2", [:fruit, "apple"]], [:item, "3", [:fruit, "pear"]]]
  end
  
  it "Illustrates NonTerminalNode#to_s" do
    BasketPeg.parse("1 apple 2 apples 3 pears").to_s.should == "1apple2apple3pear"
  end
  
  it "Illustrates NonTerminalNode#inspect" do
    BasketPeg.parse("1 apple 2 apples 3 pears").inspect.should == '[:basket, [:item, "1", [:fruit, "apple"]], [:item, "2", [:fruit, "apple"]], [:item, "3", [:fruit, "pear"]]]'
  end
  
  it "Illustrates NonTerminalNode#build" do
    BasketPeg.parse("1 apple 2 apples 3 pears").visit.should == [["1", "apple"], ["2", "apple"], ["3", "pear"]]
    class BasketPegBuilderExample
      attr_accessor :total
      
      def initialize
        @total = 0
      end
      
      def item(number,kind)
        @total = @total + (number.to_f * kind.visit(self).to_f)
      end
      
      def fruit(kind_of_fruit)
        case kind_of_fruit
        when "apple"; 3.0
        when "pear"; 1.0
        else  10.0
        end
      end
    end
    counter = BasketPegBuilderExample.new
    BasketPeg.parse("1 apple 2 apples 3 pears").visit(counter)
    counter.total.should == 12.0
  end
  
  it "Illustrates NonTerminalNode#children" do
    basket = BasketPeg.parse("1 apple 2 apples 3 pears")
    basket.class.should == Array
    basket.size.should == 3
    basket.first.should be_kind_of(NonTerminalNode)
    basket.first.type.should == :item
    basket.first.class.should == Array
    basket.first.size.should == 2
    basket.first.first.should be_kind_of(TerminalNode)
    basket.first.first.should == "1"
    basket.first.last.should be_kind_of(NonTerminalNode)
    basket.first.last.type == :fruit
    basket.first.last.class.should == Array
    basket.first.last.size.should == 1
    basket.first.last.first.should be_kind_of(TerminalNode)
    basket.first.last.first.should == "apple"
  end
  
end