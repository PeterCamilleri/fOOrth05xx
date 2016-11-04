#==== fOOrth_modes.rb
#Mode control for the fOOrth language system.
module XfOOrth
  module Compiler
    #Start compiling a fOOrth definition.
    #==== Parameters
    #* ctrl - The control symbol or string that started the compilation.
    def begin_compile_mode(ctrl)
      check_mode([:Execute])
      new_word = Word.new(parser.get_word)
      action = lambda {|&block| new_word.block = block; new_word }
      ctrl_push [ctrl, action, @level]
      @mode, @buffer, @level = :Compile, Word.preamble, @level+1
    end
    
    #Finish compiling a fOOrth definition.
    #==== Parameters
    #* ctrl - The control symbol or string that started the compilation.
    #==== Returns
    #The newly created fOOrth definition object.
    def end_compile_mode(ctrl)
      check_all([:Compile], ctrl)
      check, action, level = ctrl_pop
      @buffer << POSTAMBLE
      
      if @debug
        puts unless check == 'does:'
        puts "#{check} #{@buffer}"
      end
      
      new_word = action.call(&eval(@buffer))
      dictionary.add(new_word)
      @mode, @buffer, @level = :Execute, nil, level
      
      if @debug
        puts "Added '#{new_word.name}' to the dictionary." 
        puts
      end
      
      new_word
    end

    #While compiling, suspend compiling so that some code may be executed.    
    #==== Parameters
    #* ctrl - The control symbol or string that suspended the compilation.
    def suspend_compile_mode(ctrl)
      check_mode([:Compile])
      ctrl_push [ctrl, nil, level]
      @mode, @level = :Execute, @level+1
    end
    
    #While compiling and compiling is suspended, resume normal compiling.
    #==== Parameters
    #* ctrl - An array of control symbols or strings that could have 
    #  suspended the compilation.
    def resume_compile_mode(ctrl)
      check_all([:Execute], ctrl)
      @mode, @level = :Compile, @level-1
      ctrl_pop
    end
    
    #Enter a mode where execution is deferred. If currently in :Execute
    #mode, enter :Deferred mode. If in :Compile mode, stay in that mode.
    #==== Parameters
    #* ctrl - The control symbol or string that started the deferral.
    def suspend_execute_mode(ctrl)
      check_mode([:Compile, :Deferred, :Execute])
      ctrl_push [ctrl, @mode, @level]
      @level += 1
    
      if @mode == :Execute
        @mode   = :Deferred
        @buffer = Word.preamble
      end
    end

    #If execution was previously deferred, resume the previous mode.
    #==== Parameters
    #* ctrl - The control symbol or string that started the deferral.
    def resume_execute_mode(ctrl)
      check_mode([:Compile, :Deferred])
      old_mode = @mode
      check, @mode, level = ctrl_pop
      @level -= 1
      check_ctrl(check, ctrl)
      check_level(level)
 
      if old_mode == :Deferred && @mode == :Execute
        @buffer << POSTAMBLE
        puts "block: #{@buffer}" if @debug
        block = eval(@buffer)
        block.call(self)
        @buffer = nil
      end
    end
    
    #Ensure that the mode, control symbols, and nesting levels all agree
    #with the required values.
    #==== Parameters
    #* modes - the permissible operating modes.
    #* ctrls - the allowed set of control values.
    def check_all(modes, ctrl)
      check_mode(modes)      
      check, temp, level = ctrl_peek
      check_ctrl(check, ctrl)
      check_level(level+1)
    end

    #Check that the compiler is in one of the expected modes.    
    #==== Parameters
    #* modes - the permissible operating modes.
    def check_mode(modes)
      unless modes.include?(@mode)
        fail XfOOrthError, "Compiler Mode Error: #{modes} vs #{@mode.inspect}"
      end
    end

    #Check that the control symbol agrees with the expected value.
    #==== Parameters
    #* check - the actual control value.
    #* ctrls - the allowed set of control values.
    def check_ctrl(check, ctrl)
      unless ctrl.include?(check)
        fail XfOOrthError, "Syntax Error #{ctrl} vs #{check}"
      end
    end
    
    #Check that the nesting level agrees with the expected value.
    #==== Parameters
    #* level - the computed nesting level, to be tested against
    #  the actual nesting level.
    def check_level(level)    
      if level != @level
        fail XfOOrthError, "Nesting Error: #{@level} vs #{level}"
      end
    end    
  end  
end
