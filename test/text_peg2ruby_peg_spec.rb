$:.unshift File.join(File.dirname(__FILE__), *%w[.])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'ruby_peg'
require 'text_peg'
require 'text_peg2ruby_peg'

describe TextPeg2RubyPeg do

  def check(input,output)
    ruby = TextPeg2RubyPeg.new
    peg = TextPeg.parse(input)
    peg.build(ruby)
    ruby.to_ruby.should == output
  end  

  it "creates a class that extends RubyPeg and is named after the first rule" do
input = <<END
  one = .
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    any_character
  end
  
end
END
  check input, output
  end

    it "creates sequences" do
input = <<END
  one = . . .
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    any_character && any_character && any_character
  end
  
end
END
    check input, output
    end

    it "creates alternatives" do
input = <<END
  one = . | . | .
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    any_character || any_character || any_character
  end
  
end
END
    check input, output
    end

  it "creates alternatives and sequences together" do
input = <<END
  one = (. .) | .
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    (any_character && any_character) || any_character
  end
  
end
END
  check input, output
  end

    it "creates nodes" do
input = <<END
  one := . . .
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    node :one do
      any_character && any_character && any_character
    end
  end
  
end
END
    check input, output
    end

    it "creates positive and negative lookaheads and ignores" do
input = <<END
  one = !. &. `.
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    not_followed_by { any_character } && followed_by { any_character } && ignore { any_character }
  end
  
end
END
    check input, output
    end

    it "creates repeated occurrence suffixes" do
input = <<END
  one = .? .+ .*
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    optional { any_character } && one_or_more { any_character } && any_number_of { any_character }
  end
  
end
END
    check input, output
    end

    it "creates terminal strings" do
input = <<END
  one = "one"
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    terminal("one")
  end
  
end
END
    check input, output
    end

    it "creates terminal strings, escaping where relevant" do
input = <<END
  one = '"'
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    terminal("\\"")
  end
  
end
END
    check input, output
    end

    it "creates terminal character ranges" do
input = <<END
  one = [a-z]
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    terminal(/[a-z]/)
  end
  
end
END
    check input, output
    end

    it "creates terminal regular expressions" do
input = <<END
  one = /one/
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    terminal(/one/)
  end
  
end
END
    check input, output
    end

it "has a helper class method parse_to_ruby(text_peg) that does the parsing and compiling in one shot" do
input = <<END
  one = /one/
END
output = <<END
require 'ruby_peg'

class One < RubyPeg
  
  def root
    one
  end
  
  def one
    terminal(/one/)
  end
  
end
END
TextPeg2RubyPeg.parse_to_ruby(input).should == output  
end

it "has a helper class method parse_to_loaded_class(text_peg) that parses the text peg, compiles it to ruby and then evaluates it so it is immediately available" do
parser = TextPeg2RubyPeg.parse_to_loaded_class("one := /one/")
parser.parse("one").to_ast.should == [:one,"one"]
end

it "has a helper class method parse_file_to_loaded_class(filename) that loads a text peg then parses and compiles it to ruby before evaluating it so that it is immediately available" do
parser = TextPeg2RubyPeg.parse_file_to_loaded_class(File.join(File.dirname(__FILE__),'../lib/text_peg.txt'))
parser.parse("one := /one/").to_ast.should == [:text_peg, [:node, [:identifier, "one"], [:sequence, [:terminal_regexp, "one"]]]]
end

it "parses its own grammar" do
  input = IO.readlines(File.join(File.dirname(__FILE__),'../lib/text_peg.txt')).join
  output = IO.readlines(File.join(File.dirname(__FILE__),'../lib/text_peg.rb')).join
  ruby = TextPeg2RubyPeg.new
  peg = TextPeg.parse(input)
  peg.build(ruby)
  r = ruby.to_ruby
  r.should == output
end

end