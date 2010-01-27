$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'peg_leg'

class TestLeg1 < PegLeg
  def root
    node :grammar do
      optional_indent && grammar_keyword && space && grammar_name && newline && ignore {one_or_more { terminal('end') || terminal('END')}}
    end
  end

  def optional_indent
    ignore { terminal(/\s*/) }
  end
  
  def grammar_keyword
    ignore { terminal('grammar') }
  end
  
  def space
    ignore { terminal(/ +/) }
  end
  
  def newline
     ignore { terminal(/\n+\s*/m) }
  end
  
  def grammar_name
    terminal(/[a-zA-Z]+/)
  end
end


describe TestLeg1 do
  
  it "works with simple sequence" do
    grammar = <<-EOF
      grammar TestGrammar
      end
    EOF
    TestLeg1.parse(grammar).to_ast.should == [:grammar, "TestGrammar"]
  end

  it "works with simple alternatives" do
    grammar = <<-EOF
      grammar TestGrammar
      END
    EOF
    TestLeg1.parse(grammar).to_ast.should == [:grammar, "TestGrammar"]
  end

  it "works with one or more" do
    grammar = <<-EOF
      grammar TestGrammar
      endEND
    EOF
    TestLeg1.parse(grammar).to_ast.should == [:grammar, "TestGrammar"]
    grammar = <<-EOF
      grammar TestGrammar

    EOF
    TestLeg1.parse(grammar).should == nil
  end  
end
