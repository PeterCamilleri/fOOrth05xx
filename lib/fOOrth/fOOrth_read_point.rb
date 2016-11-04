#==== fOOrth_read_point.rb
#This file contains the module used as a mixin to facilitate the reading 
#of source code text from a buffer.
module XfOOrth
  #This mixin module is used to facilitate the reading 
  #of source code text from a buffer.
  module ReadPoint
    #Reset the read point to the initial conditions. Namely,
    #no text in the buffer and not at end of line,
    def reset_read_point
      @read_point = nil
      @eol = false
    end
    
    #Read the next character of data from the source. If there
    #is nothing to read, call the block to get some more data to
    #work with.
    #==== Parameters
    #* block - A block of code that retrieves the next line of 
    #  source code to be processed.
    def read(&block)
      unless @read_point
        @read_buffer = block.call
        return nil unless @read_buffer
        @read_point = @read_buffer.each_char
      end
      
      begin
        result = @read_point.next
        @eol = false
      rescue StopIteration
        result, @read_point, @eol = ' ', nil, true
      end
      
      result
    end
    
    #Is the read point at the end of line?
    def eol?
      @eol
    end
  end
end
