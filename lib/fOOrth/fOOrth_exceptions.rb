#==== fOOrth_exceptions.rb
#Exception classes for the fOOrth language system.
module XfOOrth
  #The generalize exception used by all fOOrth specific exceptions.
  class XfOOrthError < StandardError; end
  
  #The exception raised to force the fOOrth language system to exit.
  class ForceExit    < StandardError; end  

  #The exception raised to silently force the fOOrth language system to exit.
  class SilentExit    < StandardError; end  
  
  #The exception raised to force the fOOrth language system to abort execution.
  class ForceAbort   < StandardError; end
end
