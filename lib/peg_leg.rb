class NonTerminalNode
  attr_accessor :type
  attr_accessor :children
  
  def initialize(type,children)
    self.type = type
    self.children = children
  end
  
  def to_ast
    return [type,children.to_ast] unless children.is_a? Array
    return [type,children.first.to_ast] if children.size == 1
    return [type,*children.map(&:to_ast)] if children.size >= 1
    return [type]
  end

  def inspect; "[#{type},#{children.map(&:inspect).join(',')}]" end
  alias :to_s :to_ast
end

class TerminalNode
  attr_accessor :text
  attr_accessor :start_index, :end_index
    
  def initialize(text)
    self.text = text
  end
  
  def to_ast
    text
  end
  
  def inspect; text.inspect end
  def to_s; text.to_s end
end

class PegLeg
  
  def self.parse(text)
    self.new.parse(text)
  end
  
  def self.parse_and_dump(text)
    e = new
    r = e.parse(text)
    e.pretty_print_cache
    r
  end
  
  attr_accessor :index, :text, :cache, :sequences
  
  def parse(text)
    self.index = 0
    self.text = text
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
    case t
    when String
      if self.index == text.index(t,self.index)
        self.index = self.index + t.size
        return TerminalNode.new(t)
      end
    when Regexp
      if self.index == text.index(t,self.index)
        match = Regexp.last_match
        self.index = match.end(0)
        return TerminalNode.new(match[0])
      end
    end
    return nil
  end
  
  def uncached_node(type,&block)
    start_index = self.index
    results = sequence(&block)
    if results
      if results.is_a?(Array) && (results.size == 1) && results.first.is_a?(Array)
        return NonTerminalNode.new(type,results.first)
      else
        return NonTerminalNode.new(type,results)
      end
    else
      self.index = start_index
      return nil
    end
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
    (0...text.size).each do |i|
      print "#{text[i].inspect[1...-1]}\t#{i}\t"
      @cache.each do |name,indexes|
        result = indexes[i]
        print "[#{name.inspect},#{result.first.inspect}] " if result
      end
      print "\n"
    end
  end
  
end