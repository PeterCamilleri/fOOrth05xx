#==== fOOrth_sym_hierarchy.rb
#A hierarchical string to symbol mapping facility of the fOOrth language system.
module XfOOrth
  require_relative 'fOOrth_sym_map'
  
  #The \SymHierarchy class is used to map a hierarchy of symbols to other 
  #symbols that are not going to conflict with existing symbols. This class
  #is fairly tightly linked to the SymMap class as the two work closely
  #together to map symbols for fOOrth.
  class SymHierarchy
    #The list of SymMap objects in order of precedence
    attr_reader :list
    
    #Build a new hierarchy for symbols built on the previous hierarchy or base
    #symbol mapping.
    #==== Parameters
    #* previous - the SymMap, \SymHierachy or array of SymMap that this
    #  hierarchy is based on. Must respond to to_a to yield an array of SymMap.
    def initialize(previous)
      @list = previous.to_a
    end
    
    #Insert an entry to the hierarchy at the first slot.
    #==== Parameters
    #* entry - the entry to be inserted. This defaults to a new SymMap.
    def prepend(entry=SymMap.new)
      @list.insert(0, entry)
    end

    #Return this symbol hierarchy as an array of maps. 
    def to_a; @list; end

    #Add a mapping for a string to a symbol that will not collide with
    #existing symbols. 
    #==== Parameters:
    #* symbol - The _string_ to be mapped.
    #* options - Parameter splat options, see SymMap @@spec for details.
    #==== Returns:
    #A SymEntry
    def add_entry(symbol, *options)
      @list[0].add_entry(symbol, *options)
    end

    #Get the entry for the mapping string. Return nil if there is no entry.
    #==== Parameters:
    #* name - The string to be looked up.
    #==== Returns:
    #A SymEntry or nil if the symbol is not in the hierarchy.
    def map(name)
      @list.each do |st|
        entry = st.map(name)
        return entry if entry
      end
    end

    alias has_entry? map

    #Get the entry for the mapping symbol. Return nil if there is no entry.
    #==== Parameters:
    #* mapped - The mapping of the desired symbol.
    #==== Returns:
    #A SymEntry or nil if the symbol is not in the hierarchy.
    #==== Note:
    #If multiple symbols share the same mapping, the symbol returned is that
    #of the one defined last.
    def unmap(mapped)
      @list.each do |st|
        entry = st.unmap(mapped)
        return entry if entry
      end
    end
    
    alias has_mapping? unmap
  end
end