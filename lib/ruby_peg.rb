class NonTerminalNode
  attr_accessor :type
  attr_accessor :children
  
  def initialize(type,children)
    self.type = type
    self.children = children
  end
  
  def build(builder)
    return builder.send(type,*children) if builder.respond_to?(type)      
    return children.first.build(builder) if children.size == 1
    children.map { |c| c.build(builder) }      
  end
  
  def to_ast
    [type,*children.map(&:to_ast)]
  end

  def inspect; "[#{type},#{children.map(&:inspect).join(',')}]" end
  def to_s; children.map(&:to_s).join end
end

class TerminalNode
  attr_accessor :text
    
  def initialize(text)
    self.text = text
  end
  
  def build(builder)
    text
  end
  
  def to_ast
    text
  end
  
  def inspect; text.inspect end
  def to_s; text.to_s end
end

class RubyPeg
  
  def self.parse(text_to_parse)
    self.new.parse(text_to_parse)
  end
  
  def self.parse_and_dump(text_to_parse)
    e = new
    r = e.parse(text_to_parse)
    e.pretty_print_cache
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
    TerminalNode.new(text)
  end
  
  def uncached_node(type,&block)
    start_index = self.index
    results = sequence(&block)
    return create_non_terminal_node(type,results) if results
    self.index = start_index
    return nil
  end
  
  def create_non_terminal_node(type,children)
    return type.new(children) if type.is_a?(Class)
    NonTerminalNode.new(type,children)
  end
  
  def terminal(t)
    return put_in_sequence(cached(t)) if cached?(t)
    put_in_sequence(cache(t,self.index,uncached_terminal(t)))
  end
          
  def node(t,&block)
    return put_in_sequence(cached(t)) if cached?(t)
    put_in_sequence(cache(t,self.index,uncached_node(t,&block)))
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
  
  def pretty_print_cache
    (0...text_to_parse.size).each do |i|
      print "#{text_to_parse[i].inspect[1...-1]}\t#{i}\t"
      @cache.each do |name,indexes|
        result = indexes[i]
        print "[#{name.inspect},#{result.first.inspect}] " if result
      end
      print "\n"
    end
  end
  
end