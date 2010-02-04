$:.unshift File.join(File.dirname(__FILE__), *%w[.])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. .. lib])
require 'ruby_peg'
require 'arithmetic_peg'

describe Arithmetic do
  
  def check(text)
    puts
    e = Arithmetic.new
    e.parse(text)
    e.pretty_print_cache
    puts
  end
  
  it "parses decimal numbers, including those in scientific notation" do
    Arithmetic.parse("1").to_ast.should == [:arithmetic,'1']
    Arithmetic.parse("103.287").to_ast.should == [:arithmetic,'103.287']
    Arithmetic.parse("-1.0E-27").to_ast.should == [:arithmetic,'-1.0E-27']
  end
  
  it "parses sums of decimal numbers" do
    Arithmetic.parse("1+1").to_ast.should == [:arithmetic,[:addition,'1','1']]
  end
  
  it "parses series of sums" do
    Arithmetic.parse("1+1+2").to_ast.should == [:arithmetic,[:addition,'1',[:addition,'1','2']]]
  end
  
  it "parses a series of sums with brackets" do
    Arithmetic.parse("(1+1)+2").to_ast.should == [:arithmetic,[:addition,[:brackets,[:addition,'1','1']],'2']]
    Arithmetic.parse("1+(1+2)").to_ast.should == [:arithmetic,[:addition,'1',[:brackets,[:addition,'1','2']]]]
    Arithmetic.parse("(1+1)+(1+2)").to_ast.should == [:arithmetic,[:addition,[:brackets,[:addition,'1','1']],[:brackets,[:addition,'1','2']]]]
    Arithmetic.parse("((1+1)+(1+2))").to_ast.should == [:arithmetic,[:brackets,[:addition,[:brackets,[:addition,'1','1']],[:brackets,[:addition,'1','2']]]]]
  end
  
  it "parses subtractions" do
    Arithmetic.parse("1-1").to_ast.should == [:arithmetic,[:subtraction,'1','1']]
  end
  
  it "parses multiplication" do
    Arithmetic.parse("1*1").to_ast.should == [:arithmetic,[:multiplication,'1','1']]
  end
  
  it "parses division" do
    Arithmetic.parse("1/1").to_ast.should == [:arithmetic,[:division,'1','1']]
  end

end