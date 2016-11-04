#==== fOOrth_data_ref.rb
#The data reference class of the fOOrth language system.
module XfOOrth
  #The InstanceDataRef class is used to hold references to instance variables 
  #in the underlying Ruby underpinning of the fOOrth language system.
  class InstanceDataRef
    #Create a new instance of an instance data reference.
    #==== Parameters:
    #* obj - The object whose instance variables are to be accessed.
    #* name - The name of the instance variable to be accessed.
    def initialize(obj, name)
      @obj, @name = obj, name
    end
    
    #Read the target data.
    def data
      @obj.read_var(@name)
    end

    #Modify the target data.
    #==== Parameters:
    #* value - The new data value.    
    def data=(value)
      @obj.write_var(@name, value)
    end

    #Special handling for missing methods of the data reference.
    #==== Parameters:
    #* name - The name of the missing method.
    #* args - The arguments to that method.
    #* block - Any block argument to that method.
    def method_missing(name, *args, &block)
      fail ForceAbort, 
      "The data reference '#{@name}' does not implement #{name.inspect}."
    end
    
    #The fOOrth marker method.
    def fOOrth
    end
  end
end
