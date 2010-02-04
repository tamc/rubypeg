require 'ruby_peg'

class ArithmeticPeg < RubyPeg
  def root
    node :expression do
      one_or_more {expression}
    end
  end
  
  def expression
    subtraction || addition || division || multiplication || brackets || number
  end
  
  def brackets
    node :brackets do
      ignore { terminal("(") } && expression && ignore { terminal(")")}
    end
  end
  
  def multiplication
    node :multiplication do
      operation('*')
    end
  end
  
  def division
    node :division do 
      operation('/')
    end
  end
  
  def addition
    node :addition do
      operation('+')
    end
  end
  
  def subtraction
    node :subtraction do 
      operation('-')
    end
  end
  
  def operation(type)
    (brackets || number) && ignore { terminal(type) } && (expression)
  end
  
  def number
    terminal /[-+]?[0-9]+\.?[0-9]*([eE][-+]?[0-9]+)?/
  end
end