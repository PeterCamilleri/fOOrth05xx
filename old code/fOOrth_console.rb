#==== fOOrth_console.rb
#The fOOrth console support file.
#This file provides for the entry of fOOrth instructions from the console.
module XfOOrth
  require 'readline' #This junk has got to go!
  
  #The console class enables the use of the command line console as a source
  #for fOOrth commands and source code. The readline facility is used to enable
  #editing and command history and retrieval.
  class Console
    include Readline    #This is a stop gap measure for now.
    include ReadPoint
  
    #Initialize a new console command source.  
    define_method(:initialize) {reset_read_point}
    
    #Discard any unused input and resume.
    define_method(:flush) {reset_read_point}
    
    #Get the next character of command text from the user.
    #==== Returns
    #The next line of user input as a string.
    define_method(:get) {read { puts; readline(prompt, true).rstrip}}

    #Has the scanning of the text reached the end of input?
    #==== Returns
    #Always returns false.
    define_method(:eof?) {false}
    
    #Build the command prompt for the user based on the state 
    #of the virtual machine.
    #==== Returns
    #A prompt string.
    def prompt
      vm = Thread.current[:vm]
      '>' * vm.level + '"' * vm.quotes
    end
  end  
end
