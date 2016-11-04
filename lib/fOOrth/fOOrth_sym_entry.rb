#==== fOOrth_sym_entry.rb
#An entry in the fOOrth symbol map.
module XfOOrth
  #The \SymEntry class is used to hold the information associated with a symbol.
  class SymEntry
    #The string name of the symbol entry.
    attr_accessor :name

    #The Ruby symbol it maps to.
    attr_reader :symbol

    #The type of the symbol. See @@spec in fOOrth_sym_map for more details.
    attr_reader :type

    #Is this an immediate symbol?
    def immediate?
      @immediate
    end

    #The block associated with this symbol. 
    attr_accessor :block

    #Set up the Symbol Entry.
    def initialize(name, symbol, type, immediate, &block)
      @name = name
      @symbol = symbol
      @type = type
      @immediate = immediate
      @block = block
    end
  end
end