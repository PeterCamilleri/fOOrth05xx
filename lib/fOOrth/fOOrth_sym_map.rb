#==== fOOrth_sym_map.rb
#The string to symbol mapping facility of the fOOrth language system.
module XfOOrth
  require 'option_list'
  require_relative 'fOOrth_sym_entry'

  #The \SymMap class is used to map symbols to other symbols that are not going
  #to conflict with existing symbols. This class is fairly tightly linked to
  #the SymHierarchy class as the two work closely together to map symbols for
  #fOOrth.
  class SymMap
    @sync = Mutex.new
    @incrementer = 'aa00'
    @def_block = lambda {|*args| error "Undefined action: #{args.inspect}"}

    class << self
      attr_reader :sync
      attr_reader :incrementer
      attr_reader :def_block
    end

    #This method returns the OptionList variable that details the parameters
    #used for a symbol mapping. These are:
    #==== Category: sym_type
    #The type of symbol being mapped. These are one of the following:
    #* :empty - An empty method, no code is present or generated.
    #* :word  - A classic FORTH method. Essentially a method of the virtual machine.
    #* :class - A class definition. The block returns the class object.
    #* :method - An instance method of an arbitrary class.
    #* :local_variable - A local variable.
    #* :instance_variable - An instance variable.
    #* :thread_variable - A thread variable.
    #* :global_variable - A global variable.
    #==== Category: immediate
    #Is this an immediate symbol that executes even in compile or deferred
    #modes or is it a standard symbol that compiles or executes normally?
    #* <default> - Normal priority.
    #* :immediate - Priority execution.
    #==== Category: block
    #The action associated with this symbol. Normally, this block performs
    #that actions required by the symbol.
    #* <default> - The block raises an exception.
    #==== Validation
    #The parameters are verified to enforce the rule that only \:word and
    #\:instance_method are compatible with the \:immediate property.
    #==== Note:
    #This uses the OptionList gem.
    def self.spec;
      @spec ||= OptionList.new([:sym_type,
                                false,
                                :empty,
                                :word,
                                :class,
                                :method,
                                :dyadic,
                                :local_variable,
                                :instance_variable,
                                :thread_variable,
                                :global_variable],
                               [:immediate,
                                nil,
                                :immediate],
                               block: def_block,
                              ) do |selections|
        if selections.immediate
          sym_type = selections.sym_type

          unless [:word, :method].include? sym_type
            error "A #{sym_type} may not be marked immediate."
          end
        end
      end

      @spec
    end

    #Create a new \SymMap object.
    def initialize
      @fwd_map = Hash.new
      @rev_map = Hash.new
    end

    #Return this symbol map in an array. This is used to allow a single
    #symbol map to be used as the basis for a symbol hierarchy.
    def to_a; [self]; end

    #Add a mapping for a string to a symbol that will not collide with
    #existing symbols.
    #==== Parameters:
    #* name - The _string_ to be mapped.
    #* options - Parameter splat options, see @@spec for details.
    #==== Returns:
    #A SymEntry
    def add_entry(name, *options)
      option_list = SymMap.spec.select(options)
      error "Symbol entry for #{name} already exists" if has_entry?(name)

      SymMap.sync.synchronize do
        symbol = (SymMap.incrementer.succ!).to_sym
        entry = SymEntry.new(name,
                             symbol,
                             option_list.sym_type,
                             option_list.immediate?,
                             &option_list.block)
        @fwd_map[name]   = entry
        @rev_map[symbol] = entry
      end
    end

    #Get the entry for the mapping string. Return nil if there is no entry.
    #==== Parameters:
    #* name - The string to be looked up.
    #==== Returns:
    #A SymEntry or nil if the symbol is not in the map.
    def map(name)
      @fwd_map[name]
    end

    alias has_entry? map

    #Get the entry for the mapping symbol. Return nil if there is no entry.
    #==== Parameters:
    #* mapped - The mapping of the desired symbol.
    #==== Returns:
    #A SymEntry or nil if the symbol is not in the map.
    #==== Note:
    #If multiple symbols share the same mapping, the symbol returned is that
    #of the one defined first.
    def unmap(mapped)
      @rev_map[mapped]
    end

    alias has_mapping? unmap

    #How many entries are in the forward map? Used for testing only.
    def fwd_count; @fwd_map.count; end

    #How many entries are in the reverse map? Used for testing only.
    def rev_count; @rev_map.count; end
  end
end