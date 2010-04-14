$:.unshift File.join(File.dirname(__FILE__), *%w[.])
$:.unshift File.join(File.dirname(__FILE__), *%w[.. .. lib])
require 'textpeg2rubypeg'
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
    Formula.parse("1%").to_ast.should == [:formula,[:percentage,'1']]
    Formula.parse("103.287%").to_ast.should == [:formula,[:percentage,'103.287']]
    Formula.parse("-1.0%").to_ast.should == [:formula,[:percentage,'-1.0']]
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
    Formula.parse('"GW"&ISERR($AA$1)').to_ast.should == [:formula,[:string_join,[:string,'GW'],[:function,'ISERR',[:cell,'$AA$1']]]]
  end
  
  it "returns numeric operations" do
    Formula.parse('$A$1+$A$2+1').to_ast.should == [:formula,[:arithmetic,[:cell,'$A$1'],[:operator,"+"],[:cell,'$A$2'],[:operator,"+"],[:number,'1']]]
    Formula.parse('$A$1-$A$2-1').to_ast.should == [:formula,[:arithmetic,[:cell,'$A$1'],[:operator,"-"],[:cell,'$A$2'],[:operator,"-"],[:number,'1']]]
    Formula.parse('$A$1*$A$2*1').to_ast.should == [:formula,[:arithmetic,[:cell,'$A$1'],[:operator,"*"],[:cell,'$A$2'],[:operator,"*"],[:number,'1']]]
    Formula.parse('$A$1/$A$2/1').to_ast.should == [:formula,[:arithmetic,[:cell,'$A$1'],[:operator,"/"],[:cell,'$A$2'],[:operator,"/"],[:number,'1']]            ]
    Formula.parse('$A$1^$A$2^1').to_ast.should == [:formula,[:arithmetic,[:cell,'$A$1'],[:operator,"^"],[:cell,'$A$2'],[:operator,"^"],[:number,'1']]]
  end
  
  it "returns expressions in brackets" do
    Formula.parse('($A$1+$A$2)').to_ast.should == [:formula,[:brackets,[:arithmetic,[:cell,'$A$1'],[:operator,"+"],[:cell,'$A$2']]]]
    Formula.parse('($A$1+$A$2)+2').to_ast.should == [:formula, [:arithmetic, [:brackets, [:arithmetic, [:cell,'$A$1'], [:operator,"+"], [:cell,'$A$2']]], [:operator,"+"], [:number,'2']]]
    Formula.parse('($A$1+$A$2)+(2+(1*2))').to_ast.should == [:formula, [:arithmetic, [:brackets, [:arithmetic, [:cell,'$A$1'], [:operator,"+"], [:cell,'$A$2']]], [:operator,"+"], [:brackets, [:arithmetic, [:number,'2'], [:operator,'+'] ,[:brackets, [:arithmetic, [:number,'1'], [:operator,'*'], [:number,'2']]]]]]]  
  end
  
  it "returns comparisons" do
    Formula.parse('$A$1>$A$2').to_ast.should  == [:formula,[:comparison,[:cell,'$A$1'],[:comparator,">"],[:cell,'$A$2']]]
    Formula.parse('$A$1<$A$2').to_ast.should  == [:formula,[:comparison,[:cell,'$A$1'],[:comparator,"<"],[:cell,'$A$2']]]
    Formula.parse('$A$1=$A$2').to_ast.should  == [:formula,[:comparison,[:cell,'$A$1'],[:comparator,"="],[:cell,'$A$2']]]
    Formula.parse('$A$1>=$A$2').to_ast.should == [:formula,[:comparison,[:cell,'$A$1'],[:comparator,">="],[:cell,'$A$2']]]
    Formula.parse('$A$1<=$A$2').to_ast.should == [:formula,[:comparison,[:cell,'$A$1'],[:comparator,"<="],[:cell,'$A$2']]]
    Formula.parse('$A$1<>$A$2').to_ast.should == [:formula,[:comparison,[:cell,'$A$1'],[:comparator,"<>"],[:cell,'$A$2']]]
  end
  
  it "returns functions" do
    Formula.parse('PI()').to_ast.should  == [:formula,[:function,'PI']]
    Formula.parse('ERR($A$1)').to_ast.should  == [:formula,[:function,'ERR',[:cell,'$A$1']]]
    Formula.parse('SUM($A$1,sheet1!$1:$1000,1)').to_ast.should  == [:formula,[:function,'SUM',[:cell,'$A$1'],[:sheet_reference,'sheet1',[:row_range,'$1','$1000']],[:number,'1']]]
  end
  
  it "returns fully qualified structured references (i.e., Table[column])" do
    Formula.parse('DeptSales[Sale Amount]').to_ast.should  == [:formula,[:qualified_table_reference,'DeptSales','Sale Amount']]
    #Formula.parse("DeptSales[Sale'] Amount]").to_ast.should  == [:formula,[:qualified_table_reference,'DeptSales','Sale Amount']]
  end
  
  it "returns booleans" do
    Formula.parse("TRUE*FALSE").to_ast.should == [:formula,[:arithmetic,[:boolean_true],[:operator,'*'],[:boolean_false]]]
  end
  
  it "returns prefixes (+/-)" do
    Formula.parse("-(3-1)").to_ast.should == [:formula,[:prefix,'-'],[:brackets,[:arithmetic,[:number,'3'],[:operator,'-'],[:number,'1']]]]
  end
  
  it "returns local structured references (i.e., [column])" do
    Formula.parse('[Sale Amount]').to_ast.should  == [:formula,[:local_table_reference,'Sale Amount']]
    #Formula.parse("DeptSales[Sale'] Amount]").to_ast.should  == [:formula,[:qualified_table_reference,'DeptSales','Sale Amount']]
  end
  
  it "returns named references" do
    Formula.parse('EF.NaturalGas.N2O').to_ast.should == [:formula,[:named_reference,'EF.NaturalGas.N2O']]
  end
  
end