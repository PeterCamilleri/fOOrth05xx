#==== fOOrth_string_source.rb
#This file provides the StringSource class used to process fOOrth
#instructions from a string or an array of strings.
module XfOOrth
  require_relative 'fOOrth_read_point'

  #The StringSource class used to extract fOOrth source code
  #from an array of strings.
  class StringSource
    include ReadPoint

    #Initialize from an array of strings.
    #==== Parameters:
    #* string_list - An array of strings.
    def initialize(string_list)    
      reset_read_point
      
      if string_list.is_a?(String)
        @string_list = [ string_list ]
      else
        @string_list = string_list
      end
      
      @read_step = @string_list.each
      @eof       = false
    end

    #Skip over all remaining data in the buffers.
    def flush
      @eof = true
    end
    
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
    def eof?
      @eof
    end
  end
end
