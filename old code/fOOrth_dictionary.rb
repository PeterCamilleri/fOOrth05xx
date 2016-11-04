#==== fOOrth_dictionary.rb
#The word dictionary of the fOOrth language system.
module XfOOrth
  require_relative 'fOOrth_preload'

  #The dictionary class maintains the lists of forth words for
  #rapid lookup and retrieval.
  class Dictionary
    #A hash of all the vocabularies present in the system.
    attr_reader :vocabularies
    
    #A list of the vocabularies used to create this word space.
    attr_reader :vocabulary_list
  
    #The currently active dictionary. New definitions are
    #added to this vocabulary.
    attr_reader :current_vocabulary
    
    #The cache of currently scoped words in this word space.
    attr_reader :cache
    
    #The missing word class is used as a stand-in for dictionary
    #word entries that have gone missing for some reason.
    class MissingWord
      #Create a missing word entry.
      #==== Parameters:
      #* name - The name of the word that went missing.
      def initialize(name)
        @name = name
      end
      
      #Convert this object to a fOOrth boolean.
      def to_fOOrth_b
        false
      end

      #Special handling for missing methods of the missing word.
      #==== Parameters:
      #* name - The name of the missing method.
      #* args - The arguments to that method.
      #* block - Any block argument to that method.
      def method_missing(name, *args, &block)
        fail ForceAbort, "The word #{@name} is missing from the dictionary."
      end
      
    end
  
    #This method creates either an empty word space for the 
    #fOOrth programming language system or a shallow copy. In general, this method is
    #called with a nil or no parameter once to create the 
    #first word space. Subsequent word spaces are created 
    #passing in an other dictionary to use as a pattern.
    #==== Parameters:
    #* other - the (optional) dictionary used as the starting
    #  point for this dictionary.
    def initialize(owner, other=nil)
      @owner = owner
      
      if other.nil?
        @vocabularies           = Hash.new
        @cache                  = Hash.new {|h, k| MissingWord.new(k) }
        system                  = Hash.new {|h, k| MissingWord.new(k) }
        @current_vocabulary     = system
        @vocabularies['System'] = system
        @vocabulary_list        = [system]
      else
        @vocabularies           = other.vocabularies
        @cache                  = other.cache.clone
        @vocabulary_list        = other.vocabulary_list.clone
        @current_vocabulary     = other.current_vocabulary
      end
    end
    
    #Rebuild the cache associated with this dictionary.
    def rebuild_cache
      @cache.clear
      @vocabulary_list.each {|hash| @cache.merge!(hash)}
      @current_vocabulary = @vocabulary_list[-1]
    end
    
    #Get the entry in the cache with the specified name.
    #==== Parameters:
    #* name - the name of the word to look up in the cache.
    #==== Returns:
    #The specified word or nil if it was not found.
    def [](name)
      @cache[name]
    end
    
    #Look up the word with the given name in the cache and call it.
    #==== Parameters:
    #* name - the name to lookup and call.
    def call(name)
      @cache[name].call(@owner)
    end

    #Look up the word with a fully qualified name and call it.
    #==== Parameters:
    #* name - the name to lookup and call.
    #* vocab - the name of the vocabulary to search.
    def callq(name, vocab)
      @vocabularies[vocab][name].call(@owner)
    end
    
    #Add a \word entry to the current vocabulary of the name space.
    #==== Parameters:
    #* word - A reference to a word to be added to the dictionary.
    def add(word)
      @cache[word.name] = @current_vocabulary[word.name] = word
    end
    
    #Add a \word entry to the current vocabulary of the name space.
    #==== Parameters:
    #* new_name - The name of the new alias.
    #* old_name - The name of the existing word to be aliased. This
    #  name may either be a current name or a fully qualified name.
    def add_alias(new_name, old_name)
      sections = old_name.partition('::')
      
      if sections[1] == ''
        target = @cache[old_name].clone
      else
        vocab = vocabularies[sections[0]]
        fail XfOOrthError, "Vocabulary #{name} does not exist." if vocab.nil?        
        target = vocab[sections[2]].clone
      end

      target.name = new_name
      @cache[new_name] = @current_vocabulary[new_name] = target
      
      if @owner.debug
        puts "#{new_name} is an alias of #{old_name}"
        puts
      end
    end

    #Create a new vocabulary to hold fOOrth definitions.
    #==== Parameters:
    #* name - The name of the new vocabulary.
    #* make_current - The (optional) control over whether the new 
    #  vocabulary should be the current one. The default value is true.
    #==== Exceptions:
    #Fails with an XfOOrthError if name is in use by another vocabulary.
    def create_vocabulary(name, make_current=true)
      if @vocabularies.has_key?(name)
        fail XfOOrthError, "Vocabulary #{name} already exists."
      end
      
      new_vocabulary = Hash.new {|h, k| MissingWord.new(k) }
      @vocabularies[name] = new_vocabulary
      
      if make_current
        @current_vocabulary = new_vocabulary 
        @vocabulary_list << new_vocabulary
      end
    end
    
    #Delete the named vocabulary from the vocabulary list.
    #==== Parameters:
    #* name - The name of the old vocabulary.
    #==== Note:
    #If other name spaces are using the same vocabulary, they will
    #not be able to delete it!
    def delete_vocabulary(name)
      vocab = @vocabularies[name]
      unless vocab.nil?
        @vocabulary_list.delete(vocab)
        @vocabularies.delete(name)
        rebuild_cache
      end
    end

    #Install the given vocabulary into the current word space. If 
    #the vocabulary is already in the word space, move it to the 
    #top of the word space. The cache is rebuilt after the 
    #vocabulary is installed.
    #==== Parameters:
    #* name - The name of the new vocabulary.
    #==== Exceptions:
    #Fails with an XfOOrthError if named vocabulary does not exist.
    def install_vocabulary(name)
      vocab = @vocabularies[name]
      fail XfOOrthError, "Vocabulary #{name} does not exist." if vocab.nil?
      @vocabulary_list.delete(vocab)
      @vocabulary_list << vocab
      rebuild_cache
    end

    #Remove the given vocabulary from the current word space. The 
    #cache is rebuilt after the vocabulary is removed.
    #==== Parameters:
    #* name - The name of the old vocabulary.
    #==== Note:
    #This method does NOT fail if the vocabulary name does not exist.
    def uninstall_vocabulary(name)
      vocab = @vocabularies[name]
      
      unless vocab.nil?
        @vocabulary_list.delete(vocab)
        rebuild_cache
      end
    end
    
    #Get the name of a vocabulary hash.
    #==== Parameters:
    #* vocab - The vocabulary whose name is required.
    def query_name(vocab)
      @vocabularies.rassoc(vocab)[0]
    end
    
    #Get the name of the current vocabulary
    def query_current
      query_name(@current_vocabulary)
    end
    
    #List the words currently visible in the current name space.
    def list_words
      buffer = ''
      @cache.sort.each do |k,v|
        if v.immediate?
          temp = " #{k.ljust(12)}!"
        else
          temp = " #{k.ljust(12)} "
        end
        
        if buffer.length + temp.length > 78
          puts buffer
          buffer = ''
        end

        buffer << temp
      end
      
      puts buffer if buffer.length > 0
    end

    #List all words currently contained in all vocabularies.
    def list_all_words
      @vocabularies.sort.each do |name, words|
        puts "In vocabulary #{name}:"
        buffer = ''
        
        words.sort.each do |k,v|
          if v.immediate?
            temp = " #{k.ljust(12)}!"
          else
            temp = " #{k.ljust(12)} "
          end
          
          if buffer.length + temp.length > 78
            puts buffer
            buffer = ''
          end

          buffer << temp
        end
        
        puts buffer if buffer.length > 0
      end
    end
    
    #List all words currently contained in the path.
    def list_path_words
      @vocabulary_list.each do |words|
        puts "In vocabulary #{query_name(words)}:"
        buffer = ''
        
        words.sort.each do |k,v|
          if v.immediate?
            temp = " #{k.ljust(12)}!"
          else
            temp = " #{k.ljust(12)} "
          end
          
          if buffer.length + temp.length > 78
            puts buffer
            buffer = ''
          end

          buffer << temp
        end
        
        puts buffer if buffer.length > 0
      end
    end
    
    #List the vocabularies present in the current word space.
    def list_vocabularies
      buffer = ''
      @vocabularies.sort.each do |k,v|
      temp = " #{k.ljust(12)} "
        
        if buffer.length + temp.length > 78
          puts buffer
          buffer = ''
        end

        buffer << temp
      end
      
      puts buffer if buffer.length > 0
    end
    
    #List the vocabularies that are in the current words space path.
    def list_path
      tween = ''
      buffer = ''
      
      @vocabulary_list.reverse_each do |dict|
        vocab = query_name(dict)
        buffer << tween
        buffer << vocab
        tween = ' | '
      end
      
      puts buffer
    end
    
    #The fOOrth marker method.
    def fOOrth
    end
  end
end
