#==== fOOrth_string_list.rb
#This file provides the StringSource class used to process fOOrth
#instructions from an array of strings.
module XfOOrth
  #The StringSource class used to extract fOOrth source code
  #from an array of strings.
  class StringSource
    include ReadPoint

    #Initialize from an array of strings.
    #==== Parameters:
    #* string_list - An array of strings.
    def initialize(string_list)    
      reset_read_point    
      @string_list = string_list
      @read_step   = @string_list.each
      @eof = false
    end

    #Skip over all remaining data in the buffers.
    define_method(:flush) {@eof = true}
    
    #Get the next character of input data
    #==== Returns:
    #The next character or nil if none are available.
    def get
      return nil if @eof
      
      read do
        begin
          @read_step.next.rstrip
        rescue StopIteration
          @eof = true
          nil
        end
      end
    end

    #Has the source reached the end of the available data?
    #==== Returns:
    #True if the end is reached else false.
    define_method(:eof?) {@eof}
  end
end
