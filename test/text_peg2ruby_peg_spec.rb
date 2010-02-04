$:.unshift File.join(File.dirname(__FILE__), *%w[.])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'peg_leg'
require 'text_peg'
require 'text_peg2ruby_peg'

describe TextPeg2RubyPeg do

  def check(input,output)
    ruby = TextPeg2RubyPeg.new
    peg = TextPeg.parse(input)
    peg.build(ruby)
    ruby.to_ruby.should == output
  end  

  it "creates a class that extends PegLeg and is named after the first rule" do
input = <<END
  one = .
END
output = <<END
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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
require 'peg_leg'

class One < PegLeg
  
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

it "parses its own grammar" do
  input = IO.readlines(File.join(File.dirname(__FILE__),'../lib/text_peg.txt')).join
  ruby = TextPeg2RubyPeg.new
  peg = TextPeg.parse(input)
  peg.build(ruby)
  r = ruby.to_ruby
  # File.open(File.join(File.dirname(__FILE__),'../lib/compiled_text_peg.rb'),'w') { |f| f.puts r }
  r.should_not == nil
end

end