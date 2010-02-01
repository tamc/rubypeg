$:.unshift File.join(File.dirname(__FILE__), *%w[.])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. .. lib])
require 'peg_leg'
require 'excel_peg'

describe ExcelPeg do
  
  def check(text)
    puts
    e = ExcelPeg.new
    e.parse(text)
    e.pretty_print_cache
    puts
  end
  
  it "returns formulas" do
    ExcelPeg.parse('').to_ast.should == [:formula,""]
  end
  
  it "returns cells" do
    ExcelPeg.parse('$A$1').to_ast.should == [:formula,[:cell,'$A$1']]
    ExcelPeg.parse('A1').to_ast.should == [:formula,[:cell,'A1']]    
    ExcelPeg.parse('$A1').to_ast.should == [:formula,[:cell,'$A1']]    
    ExcelPeg.parse('A$1').to_ast.should == [:formula,[:cell,'A$1']]    
    ExcelPeg.parse('AAA1123').to_ast.should == [:formula,[:cell,'AAA1123']]
  end
  
  it "returns areas" do
    ExcelPeg.parse('$A$1:$Z$1').to_ast.should == [:formula,[:area,'$A$1','$Z$1']]
    ExcelPeg.parse('A1:$Z$1').to_ast.should == [:formula,[:area,'A1','$Z$1']]    
  end
  
  it "returns row ranges" do
    ExcelPeg.parse('$1:$1000').to_ast.should == [:formula,[:row_range,'$1','$1000']]
    ExcelPeg.parse('1000:1').to_ast.should == [:formula,[:row_range,'1000','1']]    
  end
  
  it "returns column ranges" do
    ExcelPeg.parse('$C:$AZ').to_ast.should == [:formula,[:column_range,'$C','$AZ']]
    ExcelPeg.parse('C:AZ').to_ast.should == [:formula,[:column_range,'C','AZ']]    
  end
  
  it "returns references to other sheets" do
    ExcelPeg.parse('sheet1!$A$1').to_ast.should == [:formula,[:simple_sheet,'sheet1',[:cell,'$A$1']]]    
    ExcelPeg.parse('sheet1!$A$1:$Z$1').to_ast.should == [:formula,[:simple_sheet,'sheet1',[:area,'$A$1','$Z$1']]]
    ExcelPeg.parse('sheet1!$1:$1000').to_ast.should == [:formula,[:simple_sheet,'sheet1',[:row_range,'$1','$1000']]]
    ExcelPeg.parse('sheet1!$C:$AZ').to_ast.should == [:formula,[:simple_sheet,'sheet1',[:column_range,'$C','$AZ']]]
  end
  
  it "returns references to other sheets with extended names" do
    ExcelPeg.parse("'sheet 1'!$A$1").to_ast.should == [:formula,[:quoted_sheet,'sheet 1',[:cell,'$A$1']]]    
    ExcelPeg.parse("'sheet 1'!$A$1:$Z$1").to_ast.should == [:formula,[:quoted_sheet,'sheet 1',[:area,'$A$1','$Z$1']]]
    ExcelPeg.parse("'sheet 1'!$1:$1000").to_ast.should == [:formula,[:quoted_sheet,'sheet 1',[:row_range,'$1','$1000']]]
    ExcelPeg.parse("'sheet 1'!$C:$AZ").to_ast.should == [:formula,[:quoted_sheet,'sheet 1',[:column_range,'$C','$AZ']]]
  end
  
  it "returns numbers" do
    ExcelPeg.parse("1").to_ast.should == [:formula,[:number,'1']]
    ExcelPeg.parse("103.287").to_ast.should == [:formula,[:number,'103.287']]
    ExcelPeg.parse("-1.0E-27").to_ast.should == [:formula,[:number,'-1.0E-27']]
  end

  it "returns percentages" do
    ExcelPeg.parse("1%").to_ast.should == [:formula,[:percentage,'1%']]
    ExcelPeg.parse("103.287%").to_ast.should == [:formula,[:percentage,'103.287%']]
    ExcelPeg.parse("-1.0%").to_ast.should == [:formula,[:percentage,'-1.0%']]
  end
  
  it "returns strings" do
    ExcelPeg.parse('"A handy string"').to_ast.should == [:formula,[:string,"A handy string"]]
    ExcelPeg.parse('"$A$1"').to_ast.should == [:formula,[:string,"$A$1"]]  
  end
  
  it "returns string joins" do
    check '"A handy string"&$A$1'
    ExcelPeg.parse('"A handy string"&$A$1').to_ast.should == [:formula,[:string_join,[:string,"A handy string"],[:cell,'$A$1']]]
    ExcelPeg.parse('$A$1&"A handy string"').to_ast.should == [:formula,[:string_join,[:cell,'$A$1'],[:string,"A handy string"]]]
    ExcelPeg.parse('$A$1&"A handy string"&$A$1').to_ast.should == [:formula,[:string_join,[:cell,'$A$1'],[:string,"A handy string"],[:cell,'$A$1'],]]
    ExcelPeg.parse('$A$1&$A$1&$A$1').to_ast.should == [:formula,[:string_join,[:cell,'$A$1'],[:cell,'$A$1'],[:cell,'$A$1'],]]
    
  end
  
end