class String
  
  def to_class_name
    # Taken from ActiveSupport inflector
    self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
  
  def to_method_name
    # Taken from ActiveSupport inflector
    self.gsub(/::/, '/').
       gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
       gsub(/([a-z\d])([A-Z])/,'\1_\2').
       tr("-", "_").
       downcase
  end
  
end

class Peg2Ruby
  
  attr_accessor :ruby,:tabs
  
  def initialize
  end
  
  def grammar(*definitions)
    self.ruby = []
    @tabs = 0
    @first_definition = true
    definitions.map { |d| d.build(self) }
    close_class
  end
  
  def definition(name,expression)
    if @first_definition
      define_class(name.text) 
      define_root(name.text)
    end
    line "def #{name.text.to_method_name}"
    indent
    line expression.build(self)
    outdent
    line "end"
    line
  end
  
  def node(name,expression)
    if @first_definition
      define_class(name.text) 
      define_root(name.text)
    end
    line "def #{name.text.to_method_name}"
    indent
    line "node :#{name.text.to_method_name} do"
    indent
    line expression.build(self)
    outdent
    line "end"
    outdent
    line "end"
    line
  end
  
  def define_class(name)
    line "require 'peg_leg'"
    line ""
    line "class #{name.to_class_name} < PegLeg"
    indent
    line
    @first_definition  = false
  end
  
  def define_root(name)
    line "def root"
    indent
    line name.to_method_name
    outdent
    line "end"
    line
  end
  
  def not_followed_by(element)
    "not_followed_by { #{element.build(self)} }"
  end
  
  def followed_by(element)
    "followed_by { #{element.build(self)} }"
  end
  
  def ignored(element)
    "ignore { #{element.build(self)} }"
  end
    
  def optional(element)
    "optional { #{element.build(self)} }"
  end
  
  def one_or_more(element)
    "one_or_more { #{element.build(self)} }"
  end
  
  def any_number_of(element)
    "any_number_of { #{element.build(self)} }"
  end
  
  def sequence(*elements)
    elements.map { |e| e.build(self) }.join(" && ")
  end
  
  def alternatives(*elements)
    elements.map { |e| e.build(self) }.join(" || ")    
  end
  
  def bracketed_expression(expression)
    "(#{expression.build(self)})"
  end
  
  def terminal_string(string)
    %Q{terminal("#{string.build(self)}")}
  end

  
  def terminal_regexp(regexp)
    "terminal(/#{regexp.build(self)}/)"
  end
  
  def terminal_character_range(regexp)
    "terminal(/#{regexp.build(self)}/)"
  end
  
  def any_character
    "any_character"
  end
  
  def close_class
    outdent
    line "end\n"
  end
  
  def line(string = "")
    ruby << "#{"  "*tabs}#{string}"
  end
  
  def indent
    self.tabs = tabs + 1
  end
  
  def outdent
    self.tabs = tabs - 1
  end
  
  def to_ruby
    ruby.join("\n")
  end
  
end