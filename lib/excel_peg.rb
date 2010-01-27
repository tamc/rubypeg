require 'peg_leg'

module ExcelReferencePeg
  def any_reference
    quoted_sheet_reference || simple_sheet_reference || all_reference_types
  end
  
  def quoted_sheet_reference
    node :quoted_sheet do
      ignore { terminal("'") } && terminal(/[^']+/) && ignore { terminal("'") } && sheet_separator && all_reference_types
    end
  end
  
  def simple_sheet_reference
    node :simple_sheet do
      terminal(/[a-zA-Z][\w_]+/) && sheet_separator && all_reference_types
    end
  end

  def sheet_separator
    ignore { terminal('!') }
  end
  
  def all_reference_types
    range || cell
  end
  
  def range
    column_range || row_range || area 
  end
  
  def column_range
    node :column_range do
      column && range_separator && column
    end
  end
  
  def row_range
    node :row_range do
      row && range_separator && row
    end
  end
  
  def area
    node :area do
      reference && range_separator && reference
    end
  end
  
  def range_separator
    ignore { terminal(':') }
  end
  
  def cell
    node :cell do
      reference
    end
  end
  
  def row
    terminal /\$?\d+/
  end
  
  def column
    terminal /\$?[A-Z]+/
  end
  
  def reference
    terminal(/\$?[A-Z]+\$?[0-9]+/)
  end
end

module NumberPeg
  def number
    node :number do
      terminal /[-+]?[0-9]+\.?[0-9]*([eE][-+]?[0-9]+)?/
    end
  end
  
  def percentage
    node :percentage do
      terminal /[-+]?[0-9]+\.?[0-9]*%/
    end
  end
  
end

class ExcelPeg < PegLeg
  include ExcelReferencePeg
  include NumberPeg
  
  def root
    node :formula do
      one_or_more { any_reference || percentage || number } || terminal(/.*/)
    end
  end
  
end

