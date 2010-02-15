require 'text_peg'

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
  

  def TextPeg2RubyPeg.parse_to_ruby(text_peg)
    TextPeg.parse(text_peg).build(TextPeg2RubyPeg.new)
  end

  def TextPeg2RubyPeg.parse_to_loaded_class(text_peg)
    builder = TextPeg2RubyPeg.new
    ruby =  TextPeg.parse(text_peg).build(builder)
    Kernel.eval(ruby)
    Kernel.eval(builder.class_name)
  end

  def TextPeg2RubyPeg.parse_file_to_loaded_class(filename)
    parse_to_loaded_class IO.readlines(filename).join
  end
  
  attr_accessor :ruby,:tabs,:class_name #:nodoc:
  
  RESERVED_WORDS = %w{index text_to_parse cache sequences parse ignore any_character optional one_or_more any_number_of sequence followed_by not_followed_by uncached_terminal uncached_terminal_regexp uncached_terminal_string create_terminal_node create_non_terminal_node uncached_node terminal node put_in_sequence cached? cached cache pretty_print_cache}   #:nodoc:
  
  def identifier(name) #:nodoc:
    return name.to_s unless RESERVED_WORDS.include?(name.to_s)
    $stderr.puts "Identifier #{name} clashes with a reserved word in the parser, replacing with _#{name}"
    "_#{name}"
  end
  
  def text_peg(*definitions) #:nodoc:
    self.ruby = []
    self.tabs = 0
    definitions.map { |d| d.build(self) }
    close_class
    to_ruby
  end
  
  def definition(identifier,expression) #:nodoc:
    non_clashing_name = identifier.build(self)
    unless class_name
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
  
  def node(identifier,expression) #:nodoc:
    original_name = identifier.to_s
    non_clashing_name = identifier.build(self)
    unless class_name
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
  
  def define_class(name) #:nodoc:
    self.class_name = name.to_class_name
    line "require 'ruby_peg'"
    line ""
    line "class #{class_name} < RubyPeg"
    indent
    line
    @first_definition  = false
  end
  
  def define_root(name) #:nodoc:
    line "def root"
    indent
    line name.to_method_name
    outdent
    line "end"
    line
  end
  
  def not_followed_by(element) #:nodoc:
    "not_followed_by { #{element.build(self)} }"
  end
  
  def followed_by(element) #:nodoc:
    "followed_by { #{element.build(self)} }"
  end
  
  def ignored(element) #:nodoc:
    "ignore { #{element.build(self)} }"
  end
    
  def optional(element) #:nodoc:
    "optional { #{element.build(self)} }"
  end
  
  def one_or_more(element) #:nodoc:
    "one_or_more { #{element.build(self)} }"
  end
  
  def any_number_of(element) #:nodoc:
    "any_number_of { #{element.build(self)} }"
  end
  
  def sequence(*elements) #:nodoc:
    elements.map { |e| e.build(self) }.join(" && ")
  end
  
  def alternatives(*elements) #:nodoc:
    elements.map { |e| e.build(self) }.join(" || ")    
  end
  
  def bracketed_expression(expression) #:nodoc:
    "(#{expression.build(self)})"
  end
  
  def terminal_string(string) #:nodoc:
    %Q{terminal(#{string.build(self).inspect})}
  end

  def terminal_regexp(regexp) #:nodoc:
    "terminal(/#{regexp.build(self)}/)"
  end
  
  def terminal_character_range(regexp) #:nodoc:
    "terminal(/#{regexp.build(self)}/)"
  end
  
  def any_character #:nodoc:
    "any_character"
  end
  
  def close_class #:nodoc:
    outdent
    line "end\n"
  end
  
  def line(string = "") #:nodoc:
    ruby << "#{"  "*tabs}#{string}"
  end
  
  def indent #:nodoc:
    self.tabs = tabs + 1
  end
  
  def outdent #:nodoc:
    self.tabs = tabs - 1
  end
  
  def to_ruby #:nodoc:
    ruby.join("\n")
  end
  
end