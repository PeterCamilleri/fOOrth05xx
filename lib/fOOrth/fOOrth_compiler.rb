#==== fOOrth_compiler.rb MASSIVE WIP!!!
#The compiler of the fOOrth language system.
module XfOOrth
  require_relative 'fOOrth_context'
  require_relative 'fOOrth_console'
  require_relative 'fOOrth_string_source'
  require_relative 'fOOrth_file_source'
  require_relative 'fOOrth_parser'
#  require_relative 'fOOrth_modes'
#  require_relative 'fOOrth_builds_does'

  #The compiler module for the fOOrth language system.
  class VirtualMachine
    #Reset the fOOrth compiler to its initial, default state.
    def compiler_reset
      @context = Context.new
      @context[:level] = 0
      @context[:quotes] = 0
      @context[:force_compile] = false
      @context[:parser] = nil
    end
    
    #The compile context
    attr_reader :context
    
    #Load the named file and execute it as fOOrth source code.
    #==== Parameters:
    #* file_name - the name of the file to be loaded.
    def execute_file(file_name)
      puts "Loading file #{file_name}..."
      execute(Parser.new(StringSource.new(IO.readlines(file_name))))
    end

    #Execute a string a fOOrth source code.
    #==== Parameters:
    #* str - the string to be executed as fOOrth source code.
    def execute_string(str)
      execute(Parser.new(StringSource.new(str.split("\n"))))
    end
    
    #Execute interactively from the command line console
    def execute_console
      execute(Parser.new(Console.new))
    end
    
    #Execute the fOOrth code supplied by the parser.
    #==== Parameters:
    #* parser - An instance of the Parser class that supplies parsed 
    #  source code to be executed.
    def execute(parser)
      # Make sure we are in :Execute mode.
      check_mode([:Execute])
      
      #Set up compiler control data
      save_parser = @context[:parser]
      @context[:parser] = parser
      @context[:level] += 1
      @context[:quotes] = 0

      #Begin the real work of executing code!
      begin
        loop do
          next_word = @parser.get_word        
          break if parser.source.eof?

          begin
            process_string(next_word) if next_word[-1] == '"'
            process = process_word?(next_word) || process_numeric?(next_word)
            abort("?#{next_word}?") unless process
          rescue XfOOrthError => e
            abort("Error detected: #{e}")
          rescue ZeroDivisionError => z
            abort("Division by Zero detected.")          
          rescue TypeError => t
            abort("Type conversion error detected. #{t}")          
          end
        end
      end
      
      #Restore compiler settings.
      @context[:parser] = save_parser
      @context[:level] -= 1
      @context[:quotes] = 0
    end

    #Attempt to process the next language token as a string value.
    #==== Returns
    #True if successful else false.
    def process_string(next_word)
      @context[:quotes] = 1
      string  = @parser.get_string
      @context[:quotes] = 0
      
      immediate   = dictionary[next_word]
      immediate &&= immediate.immediate? 
      
      if @force_compile
        @buffer << "vm.push(#{string.embed}); "
      elsif @mode == :Execute || immediate
        push(string)
      else
        @buffer << "vm.push(#{string.embed}); "
      end      
    end
    
    #Attempt to process the next language token as a fOOrth word.
    #==== Returns
    #True if successful else false.
    def process_word?(next_word)
      sections = next_word.partition('::')
      
      if sections[1] == ''
        sections[0] = nil
        word = dictionary[next_word]
      else
        vocab = dictionary.vocabularies[sections[0]]
        fail XfOOrthError, "Vocabulary #{name} does not exist." if vocab.nil?        
        word = vocab[sections[2]]
      end
      
      word = nil if word.is_a?(Dictionary::MissingWord)
   
      unless word.nil?
        if word.empty?
          @force_compile = false
        elsif @force_compile
          word.generate(self, sections[0])
          @force_compile = false
        elsif @mode == :Execute || word.immediate?
          word.call(self)
        else
          word.generate(self, sections[0])
        end
        
        true        
      end
    end
    
    #Attempt to process the next language token as a numeric value.
    #==== Returns
    #True if successful else false.
    def process_numeric?(next_word)
      number = next_word.to_fOOrth_n
      return false unless number
      
      if @mode == :Execute
        push(number)
      else
        @context << "vm.push(#{number.embed}); "
      end
      
      true
    end  
  end
end
