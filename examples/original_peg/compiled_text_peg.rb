require 'peg_leg'

class TextPeg < PegLeg
  
  def root
    text_peg
  end
  
  def text_peg
    node :text_peg do
      any_number_of { (spacing && (_node || definition)) }
    end
  end
  
  def _node
    node :node do
      identifier && assigns && expression && end_of_line
    end
  end
  
  def definition
    node :definition do
      identifier && equals && expression && end_of_line
    end
  end
  
  def identifier
    node :identifier do
      terminal(/[a-zA-Z_][a-zA-Z0-9_]*/) && spacing
    end
  end
  
  def assigns
    ignore { terminal(":=") } && spacing
  end
  
  def equals
    ignore { terminal("=") } && spacing
  end
  
  def expression
    alternatives || _sequence
  end
  
  def _sequence
    node :sequence do
      one_or_more { (elements && spacing) }
    end
  end
  
  def alternatives
    node :alternatives do
      elements && one_or_more { (divider && elements) }
    end
  end
  
  def divider
    ignore { terminal("|") } && spacing
  end
  
  def elements
    prefixed || suffixed || element
  end
  
  def prefixed
    ignored || _not_followed_by || _followed_by
  end
  
  def suffixed
    _optional || _any_number_of || _one_or_more
  end
  
  def _not_followed_by
    node :not_followed_by do
      ignore { terminal("!") } && element
    end
  end
  
  def _followed_by
    node :followed_by do
      ignore { terminal("&") } && element
    end
  end
  
  def ignored
    node :ignored do
      ignore { terminal("`") } && element
    end
  end
  
  def _optional
    node :optional do
      element && ignore { terminal("?") }
    end
  end
  
  def _any_number_of
    node :any_number_of do
      element && ignore { terminal("*") }
    end
  end
  
  def _one_or_more
    node :one_or_more do
      element && ignore { terminal("+") }
    end
  end
  
  def element
    bracketed_expression || identifier || terminal_string || terminal_regexp || terminal_character_range || _any_character
  end
  
  def bracketed_expression
    node :bracketed_expression do
      ignore { terminal("(") } && spacing && expression && ignore { terminal(")") } && spacing
    end
  end
  
  def terminal_string
    node :terminal_string do
      single_quoted_string || double_quoted_string
    end
  end
  
  def double_quoted_string
    ignore { terminal("\"") } && terminal(/[^"]*/) && ignore { terminal("\"") } && spacing
  end
  
  def single_quoted_string
    ignore { terminal("'") } && terminal(/[^']*/) && ignore { terminal("'") } && spacing
  end
  
  def terminal_character_range
    node :terminal_character_range do
      terminal(/\[[a-zA-Z\-0-9]*\]/) && spacing
    end
  end
  
  def terminal_regexp
    node :terminal_regexp do
      ignore { terminal("/") } && terminal(/(\\\/|[^\x2f])*/) && ignore { terminal("/") } && spacing
    end
  end
  
  def _any_character
    node :any_character do
      ignore { terminal(".") } && spacing
    end
  end
  
  def end_of_line
    ignore { terminal(/[\n\r]+/) }
  end
  
  def spacing
    ignore { terminal(/[ \t]*/) }
  end
  
end
