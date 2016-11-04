#==== fOOrth_context.rb
#The nestable compiler context class of the fOOrth language system.
module XfOOrth
  require_relative 'fOOrth_sym_map'
  require 'option_list'

  #The \Context class is used to maintain information about the
  #compilation process as it proceeds.
  class Context   # ??? WIP - to be merged into VirtualMachine class.
    modes = [:mode, false, :Compile, :Deferred, :Execute]
    @open_spec = OptionList.new(modes, prefix: 'lambda {', sym_map: nil)
    @nest_spec = OptionList.new(modes, prefix: 'lambda {')

    class << self
      #The OptionList specification for opening a context.
      attr_reader :open_spec

      #The OptionList specification for nesting a context.
      attr_reader :nest_spec
    end

    #The compile text buffer.
    attr_reader :buffer

    #Get the symbol mapping in effect for this context.
    attr_reader :sym_map

    #The context variables.
    attr_reader :info  # ??? WIP - why did I do this again?

    #Create a new compiler context object.
    def initialize   # ??? WIP - rename to initialize_context
      @contexts = []
      @sym_map  = nil
      @buffer   = nil
      @debug_buffer = 'Not setup yet.'
      @info     = Hash.new # ??? WIP - why did I do this again?
    end

    #Open up a compiling context.
    #==== Parameters:
    #* tag - The token associated with this compilation. This is usually the
    #  word that opened the context like "if" or "do".
    #* options - The following parameter options:
    #* sym_map - The symbol mapping to use for this compilation process.
    #* prefix - Additional text associated with the block source code. Often
    #  used to define block arguments and/or initialization code.
    #* mode - The mode that this process takes place in.
    def open(tag, *options)   # ??? WIP - rename to open_context
      option_list = self.class.open_spec.select(options)
      error_if_has_context
      @sym_map = option_list.sym_map || SymMap.new  # ??? WIP - will need a hierarchy...
      do_nest(tag, option_list)
    end

    #Nest a context within another or open a new context if needed.
    #==== Parameters:
    #* tag - The token associated with this compilation. This is usually the
    #  word that opened the context like "if" or "do".
    #* options - The following parameter options:
    #* prefix - Additional text associated with the block source code. Often
    #  used to define block arguments and/or initialization code.
    #* mode - The mode that this process takes place in.
    def nest(tag, *options)  # ??? WIP rename to nest_context
      do_nest(tag, self.class.nest_spec.select(options))
    end

    #The worker bee for open and nest.
    def do_nest(tag, option_list)    # ??? WIP make private
      @buffer = option_list.prefix.clone unless @buffer
      @contexts << [tag, option_list.mode, Hash.new]
    end

    #Verify that the tag of this context is one of the tags listed.
    #==== Parameters:
    #* tags - An array of allowed tag values.
    def verify_tag(tags)
      error_if_no_context

      tag = @contexts[-1][0]

      unless tags.include?(tag)
        error "Error: Found #{tag} but expected #{tags.inspect}"
      end

      tag
    end

    #Verify that the mode of this context is one of the modes listed.
    #==== Parameters:
    #* modes - An array of allowed mode values.
    def verify_mode(modes)
      unless modes.include?(mode)
        error "Error: Found #{mode} but expected #{modes.inspect}"
      end

      mode
    end

    #Extract the executable code block from the intermediate source code
    #and close off the context.
    #==== Parameters:
    #* tags - An array of allowed tag values.
    def close(tags)   # ??? WIP - rename to close_context
      @sym_map = nil
      unnest(tags)
    end

    #Un-nest a context. If this was the opening context, return the block,
    #else return nil.
    #==== Parameters:
    #* tags - An array of allowed tag values.
    def unnest(tags)  # ??? WIP rename to unnest_context
      verify_tag(tags)
      @contexts.pop

      if @contexts.empty?
        result = eval(@buffer + '}')
        @buffer, @debug_buffer = nil, @buffer
        return result
      else
        nil
      end
    end

    #Append the text to the compile buffer.
    def <<(text)   # ??? WIP - needed? I think not... delete.
      error_if_no_context
      @buffer << text
    end

    #Get the active tag.
    def tag
      error_if_no_context
      @contexts[-1][0]
    end

    #Fail if there is no context.
    def error_if_no_context
      error 'No active context.' if @contexts.empty?
    end

    #Fail if there is no context.
    def error_if_has_context
      error 'Improper context nesting' if depth > 0
    end

    #Get the current mode.
    def mode
      depth == 0 ? :Execute : @contexts[-1][1]
    end

    #How deeply nested are we here?
    def depth
      @contexts.length
    end

    #Read a context variable
    def [](name)  # ??? WIP - need to think this through...
      @info ? @info[name] : nil
    end

    #Set a context variable
    def []=(name, value)   # ??? WIP - need to think this through...
      @info[name] = value if @info
    end
  end
end