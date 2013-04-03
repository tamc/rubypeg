# RubyPeg

RubyPeg helps you to create readable Parsing Expression Grammars (PEG) in ruby.

This software is (c) 2010 Green on Black Ltd and distributed under the open source [MIT licence](http://www.opensource.org/licenses/mit-license.php). (See LICENCE for the wording).

If you like this code, employ us: http://www.greenonblack.com

## An example

    class Arithmetic < RubyPeg
      
      def root
        arithmetic
      end
      
      def arithmetic
        node :arithmetic do
          one_or_more { expression } && ignore { terminal(/\z/) }
        end
      end
      
      def expression
        subtraction || addition || division || multiplication || brackets || number
      end
      
      def brackets
        node :brackets do
          ignore { terminal("(") } && spacing && expression && spacing && ignore { terminal(")") }
        end
      end
      
      def multiplication
        node :multiplication do
          (brackets || number) && spacing && ignore { terminal("*") } && spacing && expression
        end
      end
      
      def division
        node :division do
          (brackets || number) && spacing && ignore { terminal("/") } && spacing && expression
        end
      end
      
      def addition
        node :addition do
          (brackets || number) && spacing && ignore { terminal("+") } && spacing && expression
        end
      end
      
      def subtraction
        node :subtraction do
          (brackets || number) && spacing && ignore { terminal("-") } && spacing && expression
        end
      end
      
      def number
        terminal(/[-+]?[0-9]+\.?[0-9]*([eE][-+]?[0-9]+)?/)
      end
      
      def spacing
        ignore { terminal(/[ \t]*/) }
      end
      
    end
    
    Arithmetic.parse("(1+1)+2").to_ast 
    # [:arithmetic,[:addition,[:brackets,[:addition,'1','1']],'2']]
