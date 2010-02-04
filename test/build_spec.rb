$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'ruby_peg'

class SimplePeg < RubyPeg
  def root
    node :root do 
      one && two && three
    end
  end
  
  def one
    terminal('one')
  end
  
  def two
    node :two do
      terminal('2') || terminal('two')
    end
  end
  
  def three
    node :three do
      one_or_more { terminal('x') }
    end
  end
end

describe SimplePeg do
  
  it "matches one2xxx" do
    SimplePeg.parse("one2xxx").to_ast.should == [:root,'one',[:two,'2'],[:three,'x','x','x']]
  end
end

class EmptyPegBuilder
  
end

describe EmptyPegBuilder do
  it "demonstrates the way that terminals are reduced to strings" do
    SimplePeg.parse("one2xxx").build(EmptyPegBuilder.new).should == ['one','2',['x','x','x']]
  end
end


class NonTerminalPegBuilder
  
  def root(one,two,three)
    "one:#{one},two:#{two.build(self)},three:#{three.build(self)}"
  end
  
  def two(number)
    number.build(self).to_i + 1
  end
  
  def three(*args)
    args.size
  end
  
end

describe EmptyPegBuilder do
  it "demonstrates the way that non terminals optionally call methods on the builder to be converted" do
    SimplePeg.parse("one2xxx").build(NonTerminalPegBuilder.new).should == "one:one,two:3,three:3"
  end
end

