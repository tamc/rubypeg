$:.unshift File.join(File.dirname(__FILE__), *%w[.])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. .. lib])
require 'text_peg2ruby_peg'
text_peg = IO.readlines(File.join(File.dirname(__FILE__),'excel_peg.txt')).join
ast = TextPeg.parse(text_peg)
# puts ast.to_ast
# exit
builder = TextPeg2RubyPeg.new
ruby = ast.build(builder)
Kernel.eval(ruby)

describe Formula do
  
  def check(text)
    puts
    e = Formula.new
    e.parse(text)
    e.pretty_print_cache
    puts
  end
  
  it "returns formulas" do
    Formula.parse('1+1').to_ast.first.should == :formula
  end
  
  it "returns cells" do
    Formula.parse('$A$1').to_ast.should == [:formula,[:cell,'$A$1']]
    Formula.parse('A1').to_ast.should == [:formula,[:cell,'A1']]    
    Formula.parse('$A1').to_ast.should == [:formula,[:cell,'$A1']]    
    Formula.parse('A$1').to_ast.should == [:formula,[:cell,'A$1']]    
    Formula.parse('AAA1123').to_ast.should == [:formula,[:cell,'AAA1123']]
  end
  
  it "returns areas" do
    Formula.parse('$A$1:$Z$1').to_ast.should == [:formula,[:area,'$A$1','$Z$1']]
    Formula.parse('A1:$Z$1').to_ast.should == [:formula,[:area,'A1','$Z$1']]    
  end
  
  it "returns row ranges" do
    Formula.parse('$1:$1000').to_ast.should == [:formula,[:row_range,'$1','$1000']]
    Formula.parse('1000:1').to_ast.should == [:formula,[:row_range,'1000','1']]    
  end
  
  it "returns column ranges" do
    Formula.parse('$C:$AZ').to_ast.should == [:formula,[:column_range,'$C','$AZ']]
    Formula.parse('C:AZ').to_ast.should == [:formula,[:column_range,'C','AZ']]    
  end
  
  it "returns references to other sheets" do
    Formula.parse('sheet1!$A$1').to_ast.should == [:formula,[:sheet_reference,'sheet1',[:cell,'$A$1']]]    
    Formula.parse('sheet1!$A$1:$Z$1').to_ast.should == [:formula,[:sheet_reference,'sheet1',[:area,'$A$1','$Z$1']]]
    Formula.parse('sheet1!$1:$1000').to_ast.should == [:formula,[:sheet_reference,'sheet1',[:row_range,'$1','$1000']]]
    Formula.parse('sheet1!$C:$AZ').to_ast.should == [:formula,[:sheet_reference,'sheet1',[:column_range,'$C','$AZ']]]
  end
  
  it "returns references to other sheets with extended names" do
    Formula.parse("'sheet 1'!$A$1").to_ast.should == [:formula,[:quoted_sheet_reference,'sheet 1',[:cell,'$A$1']]]    
    Formula.parse("'sheet 1'!$A$1:$Z$1").to_ast.should == [:formula,[:quoted_sheet_reference,'sheet 1',[:area,'$A$1','$Z$1']]]
    Formula.parse("'sheet 1'!$1:$1000").to_ast.should == [:formula,[:quoted_sheet_reference,'sheet 1',[:row_range,'$1','$1000']]]
    Formula.parse("'sheet 1'!$C:$AZ").to_ast.should == [:formula,[:quoted_sheet_reference,'sheet 1',[:column_range,'$C','$AZ']]]
  end
  
  it "returns numbers" do
    Formula.parse("1").to_ast.should == [:formula,[:number,'1']]
    Formula.parse("103.287").to_ast.should == [:formula,[:number,'103.287']]
    Formula.parse("-1.0E-27").to_ast.should == [:formula,[:number,'-1.0E-27']]
  end

  it "returns percentages" do
    Formula.parse("1%").to_ast.should == [:formula,[:percentage,'1%']]
    Formula.parse("103.287%").to_ast.should == [:formula,[:percentage,'103.287%']]
    Formula.parse("-1.0%").to_ast.should == [:formula,[:percentage,'-1.0%']]
  end
  
  it "returns strings" do
    Formula.parse('"A handy string"').to_ast.should == [:formula,[:string,"A handy string"]]
    Formula.parse('"$A$1"').to_ast.should == [:formula,[:string,"$A$1"]]  
  end
  
  it "returns string joins" do
    Formula.parse('"A handy string"&$A$1').to_ast.should == [:formula,[:string_join,[:string,"A handy string"],[:cell,'$A$1']]]
    Formula.parse('$A$1&"A handy string"').to_ast.should == [:formula,[:string_join,[:cell,'$A$1'],[:string,"A handy string"]]]
    Formula.parse('$A$1&"A handy string"&$A$1').to_ast.should == [:formula,[:string_join,[:cell,'$A$1'],[:string,"A handy string"],[:cell,'$A$1'],]]
    Formula.parse('$A$1&$A$1&$A$1').to_ast.should == [:formula,[:string_join,[:cell,'$A$1'],[:cell,'$A$1'],[:cell,'$A$1'],]]
    
  end
  
end