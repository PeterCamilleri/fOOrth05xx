#==== fOOrth_virtual_machine.rb
#The virtual machine that provides the platform for fOOrth code to run and
#allows words, objects, and classes to operate and interact.
module XfOOrth
  require_relative 'fOOrth_exceptions'
  require_relative 'fOOrth_class'
  require_relative 'fOOrth_compiler'

  #The fOOrth virtual machine implementation class.
  class VirtualMachine
    #The thread that this virtual machine belongs to.
    attr_reader :thread
    
    #The fOOrth data stack. This is the primary means used to hold data
    #for processing.
    attr_reader :data_stack
    
    #The fOOrth control stack. This is mostly used to hold information
    #relating to control structures during compile and interpretation.
    attr_reader :ctrl_stack
    
    #Initialize the state of the fOOrth inner interpreter. 
    def initialize
      @thread = Thread.current
      error "Only one virtual machine per thread." if @thread[:vm]
      @thread[:vm] = self
      interpreter_reset
      compiler_reset
    end

    #Reset the state of the fOOrth inner interpreter. 
    def interpreter_reset
      @data_stack = Array.new
      @ctrl_stack = Array.new
    end
    
    #Add an entry onto the data stack.
    def push(value)
      @data_stack << value
    end
    
    #Get the "top" entry from the data stack.
    #==== Note:
    #If the stack is empty this will raise a XfOOrthError exception.
    def pop
      error "Data Stack Underflow: Pop" unless @data_stack.length >= 1
      @data_stack.pop
    end
    
    #Remove multiple entries from the "top" of the data stack.
    #==== Returns:
    #An array containing the "top" n elements of the data stack.
    #==== Note:
    #If the stack has too few data, this will raise a XfOOrthError exception.
    def popm(count)
      error "Data Stack Underflow: Pop" unless @data_stack.length >= n
      @data_stack.pop(count)
    end
  
    #Remove the "top" entry from the data stack as a boolean.
    #==== Returns:
    #The "top" element of the data stack as a boolean
    #==== Note:
    #If the stack is empty this will raise a XfOOrthError exception.
    def pop?
      pop.to_fOOrth_b
    end

    #Pop a fOOrth object from the data stack. This object must be a kind
    #of XfOOrthObject or one of its subclasses.
    #==== Note:
    #If TOS not a fOOrth object or the stack is empty this will raise an 
    #XfOOrthError exception.
    def pop_object
      result = pop
      error "Receiver is not an fOOrth object." unless result.is_a?(XfOOrthObject)
      result
    end

    #Read an entry from the data stack without modify that stack.
    #==== Parameters:
    #* depth - The (optional) entry to be retrieved. 1 corresponds to the 
    #  "top" of the stack, 2 the next element, etc. 
    #  This parameter defaults to 1.
    #==== Returns:
    #The element specified from the data stack.
    #==== Note:
    #Attempting to access an element deeper than the number of elements
    #on the stack will fail with an XfOOrthError exception.
    def peek(depth=1)
      error "Data Stack Underflow: Peek" unless @data_stack.length >= n
      @data_stack[-depth]
    end

    #Read an entry from the data stack as a boolean without modify that stack.
    #==== Parameters:
    #* depth - The (optional) entry to be retrieved. 1 corresponds to the 
    #  "top" of the stack, 2 the next element, and so forth. This parameter 
    #  defaults to 1.
    #==== Returns:
    #The element specified from the data stack as a boolean.
    #==== Note:
    #Attempting to access an element deeper than the number of elements on 
    #the stack will fail with an XfOOrthError exception.
    def peek?(depth=1)
      peek(depth).to_fOOrth_b
    end

    #Add an entry to the control stack.
    def ctrl_push(value)
      @ctrl_stack << value
    end
    
    #Remove the "top" entry from the control stack.
    #==== Returns:
    #The "top" element of the control stack.
    #==== Note:
    #If the stack is empty this will raise a XfOOrthError exception.
    def ctrl_pop
      error "Control Stack Underflow: Pop" unless @ctrl_stack.length >= 1
      @ctrl_stack.pop
    end
    
    #Read an entry from the control stack without modify that stack.
    #==== Parameters:
    #* depth - The (optional) entry to be retrieved. 1 corresponds to the "top" 
    #  of the stack, 2 the next element, etc. This parameter defaults to 1.
    #==== Returns:
    #The element specified from the control stack.
    #==== Note:
    #Attempting to access an element deeper than the number of elements on the stack will
    #fail with an XfOOrthError exception.
    def ctrl_peek(depth=1)
      error "Control Stack Underflow: Peek" unless @ctrl_stack.length >= n
      @ctrl_stack[-depth]
    end
  end
  
  #A special class to contain instances of fOOrth virtual machines.
  class XVirtualMachine < XfOOrthClass
    #Create the virtual machine class in the fOOrth hierarchy. Note that
    #this function assumes that a basic hierarchy already exists.
    def XVirtualMachine._create_initial_classes
      oc = XfOOrthClass.object_class
      vm_class = oc.create_fOOrth_subclass(nil,
                                           'VirtualMachine',
                                           XVirtualMachine)
      #work in progress.

      #Create a virtual machine for this thread.
      vm_class.create_fOOrth_instance(nil)
    end

    #Create an instance of a virtual machine.
    #==== Parameters:
    #* _vm - Ignored because the receiver IS a virtual machine.
    def create_fOOrth_instance(_vm)
      new_vm = @instance_template.new
      new_vm.init(obj)
      new_vm
    end

    #The base Ruby class for instances of this class.
    def instance_base_class
      VirtualMachine
    end
  end
end
