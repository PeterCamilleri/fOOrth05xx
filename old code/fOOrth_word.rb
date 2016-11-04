#==== fOOrth_word.rb
#This class supports the concept of a word in the fOOrth language system.
module XfOOrth
  #The Word class is used to model basic word definitions in the FORTH
  #language. While lacking the minimalistic charms of the original, it
  #forms the object oriented base for the fOOrth language.
  class Word
    #The name of this word.
    attr_accessor :name
    
    #The type of this word: :Normal, :Immediate, or :Empty
    attr_accessor :type
    
    #The code block associated with this word.
    attr_accessor :block
    
    #Get the preamble used for code blocks used by this class of
    #fOOrth words.
    def Word.preamble
      "lambda {|vm| "
    end

    #Construct an instance of a word object.
    #==== Parameters:
    #* name - The name of the new word.
    #* type - The type of the new word: :Normal, :Immediate, or :Empty
    #* block - The code block associated with this word.
    def initialize(name, type=:Normal, &block)
      @name, @type, @block = name, type, block
    end

    #Does this word have no code body?
    #==== Returns:
    #True if this is an empty word, else false.
    def empty?
      @type == :Empty
    end
    
    #Does this word have priority execution that overrides
    #the :Compile and :Deferred states?
    #==== Returns:
    #True if this is an immediate word, else false.
    def immediate?
      @type == :Immediate
    end

    #Call the code block associated with this word.
    #==== Parameters:
    #* vm - The virtual machine that is executing this word.
    #==== Block Parameters:
    #The following parameters are passed to the block contained by this word.
    #* vm - The virtual machine that is executing this word.
    def call(vm)
      @block.call(vm)
    end
    
    #Generate a call to the code block associated with this word.
    #==== Parameters:
    #* vm - The virtual machine that is compiling this word.
    #* vocab - The (optional) vocabulary to generate the call for. By
    #  default all calls are routed though the dictionary cache.
    def generate(vm, vocab=nil)
      if vocab.nil?
        vm.buffer << "vm.call(#{@name.embed}); "
      else
        vm.buffer << "vm.callq(#{@name.embed}, #{vocab.embed}); "
      end
    end
    
    #Convert this word to a form suitable for embedding in a lambda as 
    #a literal.
    def embed
      "vm.dictionary[#{@name.embed}]"
    end
    
    #Handling for missing methods of the word. Fail with an exception.
    #==== Parameters:
    #* name - The name of the missing method.
    #* args - The arguments to that method.
    #* block - Any block argument to that method.
    def method_missing(name, *args, &block)
      fail ForceAbort, 
      "The word '#{@name}' does not implement #{name.inspect}."
    end
    
    alias :call_word  :call
    
    #The fOOrth marker method.
    def fOOrth
    end    
  end
end
