$:.unshift File.join(File.dirname(__FILE__), *%w[.. .. lib])
$:.unshift File.join(File.dirname(__FILE__), *%w[.])
require 'rubypeg'
require 'arithmetic_peg'

module TerminalNode
  def build(builder)
    self.to_f
  end
end

class CalculationEngine
  
  def addition(left,right)
    left.build(self) + right.build(self)
  end
  
  def subtraction(left,right)
    left.build(self) - right.build(self)
  end
  
  def multiplication(left,right)
    left.build(self) * right.build(self)
  end
  
  def division(left,right)
    left.build(self) / right.build(self)    
  end
  
end

class Calculator
  
  def self.calculate(sum)
    ast = Arithmetic.parse(sum)
    answer = ast.build(CalculationEngine.new)
    answer
  end
  
end