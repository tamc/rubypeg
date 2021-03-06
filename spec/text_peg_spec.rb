$:.unshift File.join(File.dirname(__FILE__), *%w[.])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'rubypeg'
require 'textpeg'

describe TextPeg do
  
it "parses rules, one per line" do
input = <<END
  one = .
  two = .
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:any_character]]],[:definition,[:identifier,"two"],[:sequence,[:any_character]]]]
end

it "assigns nodes, one per line" do
input = <<END
  one := .
  two := .
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:node,[:identifier,"one"],[:sequence,[:any_character]]],[:node,[:identifier,"two"],[:sequence,[:any_character]]]]
end

it "parses terminal strings in double quotes" do
input = <<END
  one = "terminal string"
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:terminal_string,"terminal string"]]]]
end

it "parses terminal strings in single quotes" do
input = <<END
  one = 'terminal string'
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:terminal_string,"terminal string"]]]]
end

it "parses terminal character matches" do
input = <<END
  one = [a-z]
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:terminal_character_range,"[a-z]"]]]]
end

it "parses terminal regular expression matches" do
input = <<END
  one = /one/
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:terminal_regexp,"one"]]]]
end

it "parses terminal regular expression matches with tricky inners" do
input = <<END
  one = /\\/one\\/two\\/three/
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:terminal_regexp,"\\/one\\/two\\/three"]]]]
end

it "parses any character matches" do
input = <<END
  one = .
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:any_character]]]]
end

it "parses alternatives" do
input = <<END
  one = "one" | "two" | "three"
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:alternatives,[:terminal_string,"one"],[:terminal_string,"two"],[:terminal_string,"three"]]]]
end

it "parses sequences" do
input = <<END
  one = "one" "two" "three"
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:terminal_string,"one"],[:terminal_string,"two"],[:terminal_string,"three"]]]]

end

it "parses alternatives in sequences" do
input = <<END
  one = ("one"|"1") "two" ( "three" | "3" )
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:bracketed_expression, [:alternatives,[:terminal_string,"one"],[:terminal_string,'1']]],[:terminal_string,"two"],[:bracketed_expression,[:alternatives,[:terminal_string,"three"],[:terminal_string,'3']]]]]]

end

it "parses sequences in alternatives" do
input = <<END
  one = ( "one" "two" "three" ) | ("1" "2" "3")
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:alternatives,[:bracketed_expression,[:sequence,[:terminal_string,"one"],[:terminal_string,"two"],[:terminal_string,"three"]]],[:bracketed_expression,[:sequence,[:terminal_string,'1'],[:terminal_string,'2'],[:terminal_string,'3']]]]]]
end

it "parses suffix elements" do
input = <<END
  one = "one"? "two"* "three"+ ("four" | "five")?
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:optional,[:terminal_string,"one"]],[:any_number_of,[:terminal_string,"two"]],[:one_or_more,[:terminal_string,"three"]],[:optional,[:bracketed_expression,[:alternatives,[:terminal_string,"four"],[:terminal_string,"five"]]]]]]]
end

it "parses lookaheads" do
input = <<END
  one = !"one" &"two"
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:not_followed_by,[:terminal_string,"one"]],[:followed_by,[:terminal_string,"two"]]]]]
end


it "parses ignores" do
input = <<END
  one = `"one" &"two"
END
TextPeg.parse(input).to_ast.should == [:text_peg,[:definition,[:identifier,"one"],[:sequence,[:ignored,[:terminal_string,"one"]],[:followed_by,[:terminal_string,"two"]]]]]
end

it "parses its own grammar" do
  input = IO.readlines(File.join(File.dirname(__FILE__),'../lib/textpeg.txt')).join
  o = TextPeg.parse(input)
  o.should_not == nil
end
end