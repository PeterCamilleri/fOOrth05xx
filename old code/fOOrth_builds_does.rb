#==== fOOrth_builds_does.rb
#This file supports the builds/does pattern of the FORTH language system.
module XfOOrth
  #The \BuildsDoesWord class is used to model <builds does> word definitions
  #of the FORTH language. It is a stepping stone on the way to the object
  #oriented features of fOOrth.
  class BuildsDoesWord < Word
    #The does block of a <builds does> word.
    attr_accessor :does

    #The data field of a <builds does> word.
    attr_accessor :data

    #Get the preamble used for the does code blocks used by this class of
    #build <does words>.
    def BuildsDoesWord.preamble
      "lambda {|this, vm| "
    end
    
    #Call the code block associated with this word.
    #==== Parameters
    #* vm - The virtual machine that is executing this word.
    #==== Block Parameters
    #The following parameters are passed to the block contained in this word.
    #* self - a self reference. In the code block, it appears as 'this'.
    #* vm - The virtual machine that is executing this word.
    def call(vm)
      @block.call(self, vm)
    end
  end

  module Compiler
    #In a colon definition, enter the builds sub-mode.
    def enter_builds_mode
      check_all([:Compile], ['colon'])
      frame = ctrl_peek

      #Rebuild the compile buffer and add the do_build clause.
      @buffer = @buffer.gsub(/\|vm\|/, '|this, vm|') +
                "vm.do_build(this) {|that, vm| "

      original_word = frame[1].call(&lambda {|vm| })
      build_word =  BuildsDoesWord.new(original_word.name)

      #Set up the <builds control stack frame
      frame[0] = '<builds'
      frame[1] = lambda {|&block| build_word.block = block; build_word }
    end

    #In a colon definition, enter the does sub-mode.
    def enter_does_mode
      check_all([:Compile], ['<builds'])
      frame = ctrl_peek

      #Close off the compile buffer and install the <builds block.
      @buffer << "}}"
      puts "#{frame[0]} #{@buffer}" if @debug
      build_word = frame[1].call(&eval(@buffer))

      #Set up the does> control stack frame
      frame[0] = 'does>'
      frame[1] = lambda {|&block| build_word.does = block; build_word }

      #Re-task the compile buffer for the does> clause.
      @buffer = BuildsDoesWord.preamble
    end
  end

  module Interpreter
    #This function constructs the <builds does> word.
    #==== Parameters:
    #* builder - The word that is doing the building.
    #* block - The <builds block for the word being constructed.
    def do_build(builder, &block)
      does_word = BuildsDoesWord.new(parser.get_word)
      does_word.block = builder.does
      block.call(does_word, self)
      dictionary.add(does_word)
    end
  end
end
