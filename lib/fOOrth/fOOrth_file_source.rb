#==== fOOrth_file_source.rb
#This file provides the FileSource class used to process fOOrth
#instructions from a UTF-8 encoded text file.
module XfOOrth
  require_relative 'fOOrth_read_point'

  #The FileSource class used to extract fOOrth source code
  #from an array of strings.
  class FileSource
    include ReadPoint


    #Initialize from an array of strings.
    #==== Parameters:
    #* file_name - The name of the file to open.
    def initialize(file_name)    
      reset_read_point
      @file = File.new(file_name, 'r:utf-8')
      @read_step = @file.each_line
      @eof       = false
    end

    #Skip over all remaining data in the buffers.
    def flush
      @eof = true
      @file.close
      @file = nil
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
          @file.close
          @file = nil
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