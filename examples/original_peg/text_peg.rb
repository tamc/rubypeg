require 'peg_leg'

class TextPeg < PegLeg
  
  def root
    node :text_peg do 
      any_number_of { spacing && ( nodes || definitions ) }
    end
  end

  def nodes
    node :node do
      identifier && assigns && expression && end_of_line
    end
  end
  
  def definitions
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
    alternatives || _sequences
  end
  
  def _sequences
    node :sequence do
      one_or_more { elements && spacing }
    end
  end
  
  def alternatives
    node :alternatives do
      elements && one_or_more { divider && elements }
    end
  end

  def divider
    ignore { terminal("|") } && spacing
  end
  
  def elements
    ignored || negative_lookahead_element || positive_lookahead_element || optional_element || any_number_of_element || one_or_more_element || element
  end
  
  def ignored
    node :ignored do 
      ignore { terminal("`") } && element
    end
  end
  
  def negative_lookahead_element
    node :not_followed_by do
      ignore { terminal("!") } && element
    end
  end
  
  def positive_lookahead_element
    node :followed_by do
      ignore { terminal("&") } && element
    end
  end
  
  def optional_element
    node :optional do 
      element && ignore { terminal("?") }
    end
  end
  
  def any_number_of_element
    node :any_number_of do 
      element && ignore { terminal("*") }
    end
  end
  
  def one_or_more_element
    node :one_or_more do
      element && ignore { terminal("+") }
    end
  end
  
  def element
    bracketed_expression || identifier || terminal_string || terminal_regexp || terminal_character_range || any_character
  end
  
  def bracketed_expression
    node :bracketed_expression do
      open_bracket && expression && close_bracket
    end
  end
  
  def open_bracket
    ignore { terminal ('(')} && spacing
  end
  
  def close_bracket
    ignore { terminal (')')} && spacing
  end
  
  def terminal_string
    node :terminal_string do
      single_quoted_string || double_quoted_string
    end
  end
    
  def single_quoted_string
    ignore { terminal("'") } && terminal(/[^']*/) && ignore { terminal("'") } && spacing
  end
  
  def double_quoted_string
    ignore { terminal("\"") } && terminal(/[^"]*/) && ignore { terminal("\"") } && spacing
  end

  def terminal_regexp
    node :terminal_regexp do
      ignore { terminal("/") } && terminal(/(\\\/|[^\x2f])*/) && ignore { terminal("/") } && spacing
    end
  end
  
  def terminal_character_range
    node :terminal_character_range do
      terminal(/\[[a-zA-Z\-0-9]*\]/) && spacing
    end
  end
  
  def any_character
    node :any_character do 
      ignore { terminal(".") } && spacing
    end
  end
  
  def end_of_line
    ignore { terminal(/[\n\r]+/) }
  end
  
  def spacing
    ignore { terminal(/[ \t]*/)  }
  end
  
end