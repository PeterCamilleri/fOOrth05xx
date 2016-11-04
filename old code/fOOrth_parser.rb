#==== fOOrth_parser.rb
#This file define the Parser class used to process fOOrth source code.
module XfOOrth
  #The Parser class used to process fOOrth source code into chunks or words
  #using the following fOOrth syntax rules.
  # <word>          ::= {<white_space>}*  <comment_start> | <word_seq>
  # <comment_start> ::= '('
  # <word_seq>      ::= ({<word_char>}+ (<end_char>)) | 
  # >                   ({<word_char>}* ('"' <string body>))
  # <word_char>     ::= not_any('"' | <white_space> | <end of input>)
  # <end_char>      ::= (<white_space> | <end of input>)
  # <string body>   ::= {<string char> | <escape seq>}+ (<end of line> | '"')
  # <string char>   ::= not_any('\' | '"' | <ctrl_char> | <end of line>)
  # <escape seq>    ::= ('\"' | '\\' | '\' <end of line>)
  # <white_space>   ::= (' ' | <ctrl_char> | <end of line>)
  # <ctrl_char>     ::= ($00 .. $1F | $7F)
  # <end of line>   ::= condition(no more text on the current line)
  # <end of input>  ::= condition(no more text left from the source)
  #Where:
  # <A> ::= Stuff means token A is defined as Stuff.
  # A B is token/expression A followed by token/expression B.
  # A | B is token/expression A or token/expression B.
  # {A}* is zero or more repetitions of token/expression A.
  # {A}+ is one or more repetitions of token/expression A.
  # A .. B is a value range starting from A ending at B, inclusive.
  # not_any(A | B) is anything except token A or token B.
  # condition(X) describes a condition rather than actual character data.
  class Parser
    #The source of the text to be parsed. It is expected that the source
    #comply to the duck typing of the StringSource class.
    attr_reader :source
    
    #Initialize this parser.
    #==== Parameters
    #* source - The source of the text to be parsed. It is expected that
    #  the source comply to the duck typing of the StringSource class.
    def initialize(source)
      @source = source
    end
    
    #Get the next forth word from the source code source.
    def get_word
      word = ''
      
      begin
        next_char = @source.get
        return nil if next_char.nil?
      end while next_char <= ' ' || next_char == "\x7F"
      
      begin
        word << next_char
        
        #Check for the three special cases.
        break if word      == '('
        break if word      == '//'
        break if next_char == '"'
        
        next_char = @source.get
        break unless next_char
      end while next_char > ' ' &&  next_char != "\x7F"
      
      word
    end
 
    #Get the balance of a string from the source code source.
    def get_string
      done = false
      result = ''
      
      begin
        next_char = @source.get
        
        if next_char == '\\'
          result << process_backslash
        elsif next_char == '"'
          done = true
        elsif @source.eol?
          done = true
        elsif next_char >= ' ' &&  next_char != "\x7F"
          result << next_char
        end        
      end until done
    
      result
    end
    
    #Process a backlash character found within a string in the source text.
    def process_backslash
      next_char = @source.get
      
      if next_char == ' ' && @source.eol?
        next_char = @source.get
        next_char = @source.get until next_char > ' ' || @source.eol?
      elsif next_char != '\\' && next_char != '"'
        next_char = ''
      end
      
      next_char
    end
    
    #Skip over a portion of the source text, usually because it is part
    #of a comment. Skipping ends when the end character or end of source
    #are detected.
    #==== Parameters
    #* end_char - The ending character to scan for.
    def skip_over(end_char)
      until @source.eof?
        break if @source.get == end_char
      end
    end
    
    #Skip over a portion of the source text, usually because it is part
    #of a comment. Skipping ends when end of line is detected.
    def skip_to_eol
      until @source.eol?
        @source.get
      end
    end
    
  end
end