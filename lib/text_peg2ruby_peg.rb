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

class TextPeg2RubyPeg
  
  attr_accessor :ruby,:tabs
  
  RESERVED_WORDS = %w{index text_to_parse cache sequences parse ignore any_character optional one_or_more any_number_of sequence followed_by not_followed_by uncached_terminal uncached_node terminal node put_in_sequence cached? cached cache pretty_print_cache}
    
  def identifier(name)
    return name.to_s unless RESERVED_WORDS.include?(name.to_s)
    $stderr.puts "Identifier #{name} clashes with a reserved word in the parser, replacing with _#{name}"
    "_#{name}"
  end
  
  def text_peg(*definitions)
    self.ruby = []
    @tabs = 0
    @first_definition = true
    definitions.map { |d| d.build(self) }
    close_class
  end
  
  def definition(identifier,expression)
    non_clashing_name = identifier.build(self)
    if @first_definition
      define_class non_clashing_name
      define_root non_clashing_name
    end
    line "def #{non_clashing_name.to_method_name}"
    indent
    line expression.build(self)
    outdent
    line "end"
    line
  end
  
  def node(identifier,expression)
    original_name = identifier.to_s
    non_clashing_name = identifier.build(self)
    if @first_definition
      define_class non_clashing_name
      define_root non_clashing_name
    end
    line "def #{non_clashing_name.to_method_name}"
    indent
    line "node :#{original_name.to_method_name} do"
    indent
    line expression.build(self)
    outdent
    line "end"
    outdent
    line "end"
    line
  end
  
  def define_class(name)
    line "require 'ruby_peg'"
    line ""
    line "class #{name.to_class_name} < RubyPeg"
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
    %Q{terminal(#{string.build(self).inspect})}
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