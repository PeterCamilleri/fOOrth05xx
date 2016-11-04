#==== fOOrth_interpreter.rb
#The run-time interpreter module for the fOOrth language system.

module XfOOrth
  #==== fOOrth_interpreter.rb
  #The run-time interpreter module for the fOOrth language system.
  module Interpreter
    #The fOOrth data stack. This is the primary means used to hold data
    #for processing.
    attr_reader :data_stack
    
    #The fOOrth control stack. This is mostly used to hold information
    #relating to control structures during compile and interpretation.
    attr_reader :ctrl_stack
    
    #A hash of the fOOrth vocabulary of word definitions.
    attr_reader :dictionary
    
    #The debug flag. If true, the compiler generates a great
    #deal of debug output and errors perform a dump of the data
    #and control stacks. If false, none of this additional 
    #output is generated.
    attr_accessor :debug
    
    #The version string of the virtual machine.
    attr_reader   :vm_version
    
    #The sign post used for timing the execution time of code sequences.
    attr_accessor :start_time

    #Reset the state of the fOOrth inner interpreter. Note that
    #dictionary is only initialized if @dictionary is nil.
    def interpreter_reset
      @data_stack   = Array.new
      @ctrl_stack   = Array.new
      @start_time   = Time.now
    end
    
    #Add an entry to the data stack.
    #==== Parameters:
    #* d - The data to be added to the data stack.
    def push(d)
      @data_stack << d
    end
    
    #Remove the "top" entry from the data stack.
    #==== Returns:
    #The "top" element of the data stack.
    #==== Note:
    #If the stack is empty this will raise a XfOOrthError exception.
    def pop
      unless @data_stack.length >= 1
        fail XfOOrthError, "Data Stack Underflow: Pop" 
      end
      @data_stack.pop
    end

    #Remove multiple entries from the "top" of the data stack.
    #==== Returns:
    #An array containing the "top" n elements of the data stack.
    #==== Note:
    #If the stack has too few data, this will raise a XfOOrthError exception.
    def popm(n)
      unless @data_stack.length >= n
        fail XfOOrthError, "Data Stack Underflow: Pop" 
      end      
      @data_stack.pop(n)
    end
    
    #Remove the "top" entry from the data stack as a boolean.
    #==== Returns:
    #The "top" element of the data stack as a boolean
    #==== Note:
    #If the stack is empty this will raise a XfOOrthError exception.
    def pop?
      pop.to_fOOrth_b
    end
    
    #Pop an object from the data stack. This object must be compatible
    #with the class listed or the Word class by default.
    #==== Note:
    #If the stack is empty this will raise a XfOOrthError exception.
    def pop_object
      t = pop      
      unless t.respond_to?(:fOOrth)
        fail XfOOrthError, "Receiver is not an fOOrth object." 
      end
      t
    end
    
    #Read an entry from the data stack without modify that stack.
    #==== Parameters:
    #* n - The (optional) entry to be retrieved. 1 corresponds to the 
    #  "top" of the stack, 2 the next element, etc. 
    #  This parameter defaults to 1.
    #==== Returns:
    #The element specified from the data stack.
    #==== Note:
    #Attempting to access an element deeper than the number of elements
    #on the stack will fail with an XfOOrthError exception.
    def peek(n=1)
      unless @data_stack.length >= n
        fail XfOOrthError, "Data Stack Underflow: Peek"
      end
      @data_stack[-n]
    end
    
    #Read an entry from the data stack as a boolean without modify that stack.
    #==== Parameters:
    #* n - The (optional) entry to be retrieved. 1 corresponds to the "top" of the stack,
    #  2 the next element, etc. This parameter defaults to 1.
    #==== Returns:
    #The element specified from the data stack as a boolean.
    #==== Note:
    #Attempting to access an element deeper than the number of elements on the stack will
    #fail with an XfOOrthError exception.
    def peek?(n=1)
      peek(n).to_fOOrth_b
    end
    
    #Add an entry to the control stack.
    #==== Parameters:
    #* d - The data to be added to the control stack.
    def ctrl_push(d)
      @ctrl_stack << d
    end
    
    #Remove the "top" entry from the control stack.
    #==== Returns:
    #The "top" element of the control stack.
    #==== Note:
    #If the stack is empty this will raise a XfOOrthError exception.
    def ctrl_pop
      fail XfOOrthError, "Control Stack Underflow: Pop" unless @ctrl_stack.length >= 1
      @ctrl_stack.pop
    end
    
    #Read an entry from the control stack without modify that stack.
    #==== Parameters:
    #* n - The (optional) entry to be retrieved. 1 corresponds to the "top" of the stack,
    #  2 the next element, etc. This parameter defaults to 1.
    #==== Returns:
    #The element specified from the control stack.
    #==== Note:
    #Attempting to access an element deeper than the number of elements on the stack will
    #fail with an XfOOrthError exception.
    def ctrl_peek(n=1)
      fail XfOOrthError, "Control Stack Underflow: Peek" unless @ctrl_stack.length >= n
      @ctrl_stack[-n]
    end
    
    #Call the call method of the word corresponding to the name parameter.
    #==== Parameters:
    #* name - the name of word to be called.
    def call(name)
      dictionary.call(name)
    end
    
    #Call the call method of the fully qualified word corresponding 
    #to the name and vocab parameters.
    #==== Parameters:
    #* name - the name of word to be called.
    #* vocab - the vocabulary to search in.
    def callq(name, vocab)
      dictionary.callq(name, vocab)
    end
    
    #The runtime implementation of the "do" word.
    #==== Parameters:
    #* block - A block of code to be executed as the do loop body.
    #==== Block Parameters:
    #* i - The stack frame of the current loop counter. This 
    #  corresponds to the fOOrth 'i' value.
    #* j - The stack frame of any containing loop counter. This corresponds 
    #  to the fOOrth 'j' value. If there is no containing loop, this
    #  will always be a zero frame ie: [:vm_do, 0, 0, 0].
    def vm_do(&block)
      j = [:vm_do, 0, 0, 0]
      i = [:vm_do, pop, pop-1]
      i << i[1] + i[2]
      ctrl_push i
      
      if ctrl_stack.length >= 2
        outer = ctrl_peek(2)
        j = outer if outer[0] == :vm_do
      end
      
      while i[1] <= i[2]
        yield i, j
      end
      
      ctrl_pop
    end
    
  end
end

