$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'rubypeg'

class TestNegativeLookahead < RubyPeg
  def root
    node :root do 
      one_or_more { negative || word || space }
    end
  end
  
  def negative
    node :negative do
      terminal('!') && not_followed_by { terminal('!') }
    end
  end
  
  def word
    node :word do
      terminal(/\S+/)
    end
  end
  
  def space
    ignore { terminal(/\s+/) }
  end
  
end

describe TestNegativeLookahead do
  
  it "matches normally" do
    TestNegativeLookahead.parse("one two three").to_ast.should == [:root,[:word,"one"],[:word,"two"],[:word,"three"]]
  end
  
  it "inverts normally" do
    TestNegativeLookahead.parse("one !two three").to_ast.should == [:root,[:word,"one"],[:negative,"!"],[:word,"two"],[:word,"three"]]
  end
  
  it "looks ahead so as to interpret double negatives" do
    TestNegativeLookahead.parse("one !!two three").to_ast.should == [:root,[:word,"one"],[:word,"!!two"],[:word,"three"]]
  end
end

class TestPositiveLookahead < RubyPeg
  def root
    node :root do 
      one_or_more {  noun || verb || adjective || adverb || word || space }
    end
  end
  
  def adjective
    node :adjective do
      terminal(/\S+/) && followed_by { space && noun }
    end
  end
  
  def adverb
    node :adverb do
      terminal(/\S+/) && followed_by { space && verb }
    end    
  end
  
  def word
    node :word do
      terminal(/\S+/)
    end
  end
  
  def noun
    node :noun do
      terminal('dog') || terminal('fox')
    end
  end
  
  def verb
    node :verb do
      terminal('jumped') || terminal('ran')
    end    
  end
  
  def space
    ignore { terminal(/\s+/) }
  end
  
end


describe TestPositiveLookahead do
  
  it "matches normally" do
    TestPositiveLookahead.parse("black blinking").to_ast.should == [:root,[:word,"black"],[:word,"blinking"]]
  end
    
  it "matches when looking ahead" do
    TestPositiveLookahead.parse("brown dog").to_ast.should == [:root,[:adjective,"brown"],[:noun,"dog"]]
  end
  
  it "matches in slighlty more complicated squences" do
    TestPositiveLookahead.parse("brown dog jumped as it lazily ran").to_ast.should == [:root,[:adjective,"brown"],[:noun,"dog"],[:verb,"jumped"],[:word,'as'],[:word,'it'],[:adverb,'lazily'],[:verb,'ran']]
  end
end
