# This file contains all the elements thare are required
# at runtime by a RubyPeg parser.
#
# You can either distribute it in your source code
# or include the rubypeg gem as a dependency for 
# your source

# By default all non terminals that 
# are returned by RubyPeg#parse are Arrays 
# that have been extended with the NonTerminalNode
# module
#
# If we consider this example:
#   class BasketPeg < RubyPeg
#     def root
#       node :basket do
#         one_or_more { items }
#       end
#     end
#     
#     def items
#       node :item do
#         number && optional_space && fruit && optional_space
#       end
#     end
#     
#     def number
#       terminal(/\d+/)
#     end
#   
#     def fruit
#       node :fruit do
#         (terminal("apple") || terminal("pear")) && ignore{ optional{ terminal("s") } }
#       end
#     end
#     
#     def optional_space
#       ignore{ optional{ terminal(" ") }}
#     end
#   end
# Then
#   BasketPeg.parse("1 apple 2 apples 3 pears").should be_kind_of(NonTerminalNode)
#
# This is an array of children of this non terminal.
# The children may be other non-terminals or terminals
# The array will be empty if there are no children.
#
#   basket = BasketPeg.parse("1 apple 2 apples 3 pears")
#   basket.class.should == Array
#   basket.size.should == 3
#   basket.first.should be_kind_of(NonTerminalNode)
#   basket.first.type.should == :item
#   basket.first.class.should == Array
#   basket.first.size.should == 2
#   basket.first.first.should be_kind_of(TerminalNode)
#   basket.first.first.should == "1"
#   basket.first.last.should be_kind_of(NonTerminalNode)
#   basket.first.last.type == :fruit
#   basket.first.last.class.should == Array
#   basket.first.last.size.should == 1
#   basket.first.last.first.should be_kind_of(TerminalNode)
#   basket.first.last.first.should == "apple"
module NonTerminalNode
  
  # Contains the argument given to RubyPeg#node
  #   BasketPeg.parse("1 apple 2 apples 3 pears").type.should == :basket
  attr_accessor :type

  
  # This is a quick way of carrying out the visitor pattern on the parsed structure.
  # 
  # If no visitor is supplied then a nested array of child nodes is returned, with terminals turned into strings:
  #   BasketPeg.parse("1 apple 2 apples 3 pears").build.should == [["1", "apple"], ["2", "apple"], ["3", "pear"]]
  # 
  # If a visitor is supplied, then each non terminal node checks if there is a method on the visitor
  # with a name the same as the non terminal's type. If there is, then the method is called with the
  # children of the non terminal as arguments. If there isn't, then the build methods on the children
  # of this node ar recursively called.
  # E.g.,:
  #   BasketPeg.parse("1 apple 2 apples 3 pears").build.should == [["1", "apple"], ["2", "apple"], ["3", "pear"]]
  #   class BasketPegBuilderExample
  #     attr_accessor :total
  #     
  #     def initialize
  #       @total = 0
  #     end
  #     
  #     def item(number,kind)
  #       @total = @total + (number.to_f * kind.build(self).to_f)
  #     end
  #     
  #     def fruit(kind_of_fruit)
  #       case kind_of_fruit
  #       when "apple"; 3.0
  #       when "pear"; 1.0
  #       else  10.0
  #       end
  #     end
  #   end
  #   counter = BasketPegBuilderExample.new
  #   BasketPeg.parse("1 apple 2 apples 3 pears").build(counter)
  #   counter.total.should == 12.0
  def visit(builder = nil)
    return builder.send(type,*self) if builder.respond_to?(type)
    return self.first.visit(builder) if self.size == 1
    self.map { |c| c.visit(builder) }
  end
  
  # Returns the node network as an abstract syntax tree
  #
  #   BasketPeg.parse("1 apple 2 apples 3 pears").to_ast.should == [:basket, [:item, "1", [:fruit, "apple"]], [:item, "2", [:fruit, "apple"]], [:item, "3", [:fruit, "pear"]]]
  # Note that the items wrapped in ignore {} in the parser, shuch as the spaces and the optional 's' in apples and pears do not appear.
  def to_ast
    [type,*self.map(&:to_ast)]
  end
  
  # Lists the non-terminal node and its children. Same content as #to_ast but in string form.
  #   BasketPeg.parse("1 apple 2 apples 3 pears").inspect.should == '[:basket, [:item, "1", [:fruit, "apple"]], [:item, "2", [:fruit, "apple"]], [:item, "3", [:fruit, "pear"]]]'
  def inspect; to_ast.inspect end
  
  # Returns the result of calling to_s on each of its children. By default, TerminalNode#to_s returns its text value, so:
  #   BasketPeg.parse("1 apple 2 apples 3 pears").to_s.should == "1apple2apple3pear"
  # Note that the items wrapped in ignore {} in the parser, shuch as the spaces and the optional 's' in apples and pears do not appear.
  def to_s; self.map(&:to_s).join end
end

module TerminalNode
  def visit(builder)
    self
  end
  
  def to_ast
    self
  end
end

class RubyPeg
  
  # See #parse
  def self.parse(text_to_parse)
    self.new.parse(text_to_parse)
  end
  
  def self.parse_and_dump(text_to_parse, dump_positive_matches_only = false)
    e = new
    r = e.parse(text_to_parse)
    e.pretty_print_cache(dump_positive_matches_only)
    r
  end
  
  attr_accessor :index, :text_to_parse, :cache, :sequences
  
  def parse(text_to_parse)
    self.index = 0
    self.text_to_parse = text_to_parse
    self.cache = {}
    self.sequences = [[]]
    root
  end
  
  def root
    terminal(/.*/m)
  end
    
  def ignore(&block)
    result = sequence(&block)
    return :ignore if result
    nil
  end
  
  def any_character
    terminal /./
  end
  
  def optional
    return yield || :ignore
  end
  
  def one_or_more
    results = []
    while result = yield
      results << result 
    end
    return nil if results.empty?
    results
  end
  
  def any_number_of
    results = []
    while result = yield
      results << result 
    end
    results
  end
  
  def sequence
    start_index = self.index
    self.sequences.push([])
    if yield
      results = self.sequences.pop
      results.delete_if {|r| r == :ignore }
      return results
    else
      self.sequences.pop
      self.index = start_index
      return nil
    end
  end
  
  def followed_by(&block)
    start_index = self.index
    result = sequence(&block)
    self.index = start_index
    return :ignore if result
    return nil
  end
  
  def not_followed_by(&block)
    followed_by(&block) ? nil : :ignore
  end
  
  def terminal(t)
    return put_in_sequence(cached(t)) if cached?(t)
    put_in_sequence(cache(t,self.index,uncached_terminal(t)))
  end
          
  def node(t,&block)
    return put_in_sequence(cached(t)) if cached?(t)
    put_in_sequence(cache(t,self.index,uncached_node(t,&block)))
  end
      
  def pretty_print_cache(only_if_match = false)
    (0...text_to_parse.size).each do |i|
      print "#{text_to_parse[i].inspect[1...-1]}\t#{i}\t"
      @cache.each do |name,indexes|
        result = indexes[i]
        next unless result
        if only_if_match
          print "[#{name.inspect},#{result.first.inspect}] " if result.first
        else
          print "[#{name.inspect},#{result.first.inspect}] " 
        end
      end
      print "\n"
    end
  end
  
  private

  def uncached_terminal(t)
    return uncached_terminal_regexp(t) if t.is_a? Regexp
    uncached_terminal_string(t.to_s)
  end
  
  def uncached_terminal_regexp(t)
    return nil unless self.index == text_to_parse.index(t,self.index)
    match = Regexp.last_match
    self.index = match.end(0)
    create_terminal_node match[0]
  end
  
  def uncached_terminal_string(t)
    return nil unless self.index == text_to_parse.index(t,self.index)
    self.index = self.index + t.size
    create_terminal_node t
  end
  
  def create_terminal_node(text)
    text.extend(TerminalNode)
  end
  
  def uncached_node(type,&block)
    start_index = self.index
    results = sequence(&block)
    return create_non_terminal_node(type,results) if results
    self.index = start_index
    return nil
  end
  
  def create_non_terminal_node(type,children_array)
    children_array.extend(NonTerminalNode)
    children_array.type = type
    children_array
  end
  
  def put_in_sequence(result)
    self.sequences.last.push(result) if result
    result
  end
    
  def cached?(name)
    return false unless @cache.has_key?(name)
    return false unless @cache[name].has_key?(self.index)
    true
  end
  
  def cached(name)
    r = @cache[name][self.index]
    self.index = r.last
    r.first
  end
  
  def cache(name,i,result)
    if @cache.has_key?(name)
      @cache[name][i] = [result,self.index]
    else
      @cache[name] = {i => [result,self.index]}
    end
    result
  end
  
  
end