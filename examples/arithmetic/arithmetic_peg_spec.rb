$:.unshift File.join(File.dirname(__FILE__), *%w[.])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. .. lib])
require 'peg_leg'
require 'arithmetic_peg'

describe ArithmeticPeg do
  
  def check(text)
    puts
    e = ArithmeticPeg.new
    e.parse(text)
    e.pretty_print_cache
    puts
  end
  
  it "parses decimal numbers, including those in scientific notation" do
    ArithmeticPeg.parse("1").to_ast.should == [:expression,'1']
    ArithmeticPeg.parse("103.287").to_ast.should == [:expression,'103.287']
    ArithmeticPeg.parse("-1.0E-27").to_ast.should == [:expression,'-1.0E-27']
  end
  
  it "parses sums of decimal numbers" do
    ArithmeticPeg.parse("1+1").to_ast.should == [:expression,[:addition,'1','1']]
  end
  
  it "parses series of sums" do
    ArithmeticPeg.parse("1+1+2").to_ast.should == [:expression,[:addition,'1',[:addition,'1','2']]]
  end
  
  it "parses a series of sums with brackets" do
    ArithmeticPeg.parse("(1+1)+2").to_ast.should == [:expression,[:addition,[:brackets,[:addition,'1','1']],'2']]
    ArithmeticPeg.parse("1+(1+2)").to_ast.should == [:expression,[:addition,'1',[:brackets,[:addition,'1','2']]]]
    ArithmeticPeg.parse("(1+1)+(1+2)").to_ast.should == [:expression,[:addition,[:brackets,[:addition,'1','1']],[:brackets,[:addition,'1','2']]]]
    ArithmeticPeg.parse("((1+1)+(1+2))").to_ast.should == [:expression,[:brackets,[:addition,[:brackets,[:addition,'1','1']],[:brackets,[:addition,'1','2']]]]]
  end
  
  it "parses subtractions" do
    ArithmeticPeg.parse("1-1").to_ast.should == [:expression,[:subtraction,'1','1']]
  end
  
  it "parses multiplication" do
    ArithmeticPeg.parse("1*1").to_ast.should == [:expression,[:multiplication,'1','1']]
  end
  
  it "parses division" do
    ArithmeticPeg.parse("1/1").to_ast.should == [:expression,[:division,'1','1']]
  end
  
  it "parses with correct operator precedence" do
    ArithmeticPeg.parse("1*2+3").to_ast.should == [:expression,[:addition,[:multiplcation,'1','2'],'3']]
  end
  
end