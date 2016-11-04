#==== fOOrth_preload.rb
#The dictionary initializer of the fOOrth language system.
module XfOOrth
  #This file contains the singular method 
  class Dictionary
    #Load up the fOOrth dictionary with all of the standard 
    #(and many not so standard) \word definitions.
    #Initially, those words that are needed to be able to define
    #other words, and those that are hard to do in fOOrth are
    #created in Ruby.
    def load_fOOrth_kernal
      #Initially, fOOrth words are created by Ruby code. This is because
      #it is impossible to create fOOrth words with a completely empty
      #dictionary. These three words below are the minimum so far.
      add(Word.new(':') {|vm| vm.begin_compile_mode('colon')})
      add(Word.new(',asm"', :Immediate) do |vm|
        vm.suspend_execute_mode('comma_asm')
        vm.buffer << vm.pop
        vm.resume_execute_mode(['comma_asm'])
      end)
      add(Word.new(';immediate', :Immediate) do |vm| 
        vm.end_compile_mode(['colon']).type = :Immediate
      end)

      #The balance of the words are created via fOOrth source code contained
      #in the following jumbo string literal.
      fOOrth_src = <<-'END'
      : (  ,asm"vm.parser.skip_over(')') " ;immediate ( Comments now allowed! )
      : // ,asm"vm.parser.skip_over      " ;immediate // These ones too!
      
      ( Essential language support words. )
      : ;      ,asm"vm.end_compile_mode(['colon', 'does>'])"      ;immediate
      : ;empty ,asm"vm.end_compile_mode(['colon']).type = :Empty" ;immediate
      : _vm    ,asm"vm.push(vm)" ;
      : _rv"   ,asm"name=vm.pop; vm.push(vm.pop_object.read_var(name)) " ;
      : _wv"   ,asm"name=vm.pop; tgt=vm.pop_object; \
                    vm.push(tgt.write_var(name,vm.pop)) " ;
      : _av"   ,asm"name=vm.pop; tgt=vm.pop_object; \
                    vm.push(InstanceDataRef.new(tgt, name)) " ;
      : execute ,asm"vm.pop_object.call_word(vm) " ;
      
      : nop ;empty
      : "   ;empty
      : alias:    ,asm"vm.dictionary.add_alias(vm.parser.get_word, vm.pop)" ;
      ",asm\"" alias: ,asm
      : split     ,asm"vm.push(vm.pop.split)" ;

      ( Suspend execution mode. Note this is nestable! )
      : _se"      ,asm"vm.suspend_execute_mode(vm.pop)" ;
      
      ( Append to compiler buffer. )
      : _<<       ,asm"vm.buffer << vm.pop" ;
      "_<<" alias: _<<"
      
      ( Resume execution mode, unless nested. )
      : _re"      split ,asm"vm.resume_execute_mode(vm.pop)" ;

      ( Compiler mode checking words. )
      : +execute  ,asm"vm.check_mode([:Execute])" ;
      : -execute  ,asm"vm.check_mode([:Compile, :Deferred])" ;
      : +compile  ,asm"vm.check_mode([:Compile])" ;
      : +execute" split ,asm"vm.check_all([:Execute],            vm.pop)" ;
      : -execute" split ,asm"vm.check_all([:Compile, :Deferred], vm.pop)" ;
      : +compile" split ,asm"vm.check_all([:Compile],            vm.pop)" ;

      : <builds   ,asm"vm.enter_builds_mode" ;immediate
      : does>     ,asm"vm.enter_does_mode" ;immediate
      : that      +compile"<builds" _<<"vm.push(that); " ;immediate
      : this      +compile"<builds does>" _<<"vm.push(this); " ;immediate

      : [compile] +compile ,asm"vm.force_compile = true" ;immediate
      : ,         +compile ,asm"vm.buffer << \"vm.push(#{vm.pop.embed}); \"" ;
      : @         ,asm"vm.push(vm.pop_object.data)" ;
      : !         ,asm"vm.pop_object.data = vm.pop" ;
      : var:      <builds that ! does> this ;
      : ref:      <builds that ! does> this @ ;
      : const:    : , [compile] ; ;
      : fwd:      : [compile] ;  ;
      
      ( Are these next two still neded anymore? )
      : {         ,asm"vm.suspend_compile_mode('{')" ;immediate
      : }         ,asm"vm.resume_compile_mode(['{'])" ;

      ( Stack display diagnostics. )
      : dsd       ,asm"pp(vm.data_stack)" ;
      : csd       ,asm"pp(vm.ctrl_stack)" ;

      ( String manipulation words )
      : rj        ,asm"w = vm.pop; vm.push(vm.pop.to_s.rjust(w))"  ;
      : lj        ,asm"w = vm.pop; vm.push(vm.pop.to_s.ljust(w))"  ;
      : cj        ,asm"w = vm.pop; vm.push(vm.pop.to_s.center(w))" ;

      ( 'dot' based printing words. )
      : .         ,asm"print(vm.pop)" ;
      "." alias: ."
      : .r        rj . ;
      : .l        lj . ;
      : .c        cj . ;
      : cr        ,asm"puts" ;
      : space     ,asm"print ' ' " ;
      ( spaces -- See below. )
      : emit      ,asm"print vm.pop.to_fOOrth_c " ;

      ( Source code execution words. )
      : load        ,asm"vm.execute_file(vm.pop)" ;
      "load" alias: load"
      : load_string ,asm"vm.execute_string(vm.pop)" ;
      "load_string" alias: load_string" ( Why ??? )

      ( Comparison words. )
      : =         ,asm"b,a=vm.popm(2); vm.push(b==a)" ;
      : <>        ,asm"b,a=vm.popm(2); vm.push(b!=a)" ;
      : >         ,asm"b,a=vm.popm(2); vm.push(b>a)" ;
      : <         ,asm"b,a=vm.popm(2); vm.push(b<a)" ;
      : >=        ,asm"b,a=vm.popm(2); vm.push(b>=a)" ;
      : <=        ,asm"b,a=vm.popm(2); vm.push(b<=a)" ;
      : <=>       ,asm"b,a=vm.popm(2); vm.push(b<=>a)" ;

      ( Comparison with zero words. )
      : 0=        ,asm"vm.push(vm.pop==0)" ;
      : 0<>       ,asm"vm.push(vm.pop!=0)" ;
      : 0>        ,asm"vm.push(vm.pop>0)" ;
      : 0<        ,asm"vm.push(vm.pop<0)" ;
      : 0>=       ,asm"vm.push(vm.pop>=0)" ;
      : 0<=       ,asm"vm.push(vm.pop<=0)" ;
      : 0<=>      ,asm"vm.push(vm.pop<=>0)" ;

      ( Boolean const:s. )
      : true      ,asm"vm.push(true)" ;
      : false     ,asm"vm.push(false)" ;

      ( Basic arithmetic words. )
      : minus     ,asm"vm.push(-(vm.pop)) " ;
      : +         ,asm"b,a=vm.popm(2); vm.push(b+a)" ;
      : -         ,asm"b,a=vm.popm(2); vm.push(b-a)" ;
      : *         ,asm"b,a=vm.popm(2); vm.push(b*a)" ;
      : /         ,asm"b,a=vm.popm(2); vm.push(b/a)" ;
      : mod       ,asm"b,a=vm.popm(2); vm.push(b%a)" ;
      : */        ,asm"c, b,a=vm.popm(3); vm.push((c*b)/a)" ;
      : min       ,asm"b,a=vm.popm(2); vm.push(a>b ? b : a)" ;
      : max       ,asm"b,a=vm.popm(2); vm.push(a>b ? a : b)" ;

      ( Boolean logic words. )
      : and       ,asm"b,a=vm.popm(2); vm.push(b&a)" ;
      : or        ,asm"b,a=vm.popm(2); vm.push(b|a)" ;
      : xor       ,asm"b,a=vm.popm(2); vm.push(b^a)" ;
      : not       ,asm"vm.push(!vm.pop?)" ;
      : invert    ,asm"vm.push(~vm.pop)"  ;

      ( Increment/decrement words. )
      : 1+        ,asm"vm.push(vm.pop+1)" ;
      : 1-        ,asm"vm.push(vm.pop-1)" ;
      : 2+        ,asm"vm.push(vm.pop+2)" ;

      ( Data type conversions )
      : to_s      ,asm"vm.push(vm.pop.to_s)" ;
      : to_i      ,asm"vm.push(vm.pop.to_i)" ;
      : to_f      ,asm"vm.push(vm.pop.to_f)" ;
      : to_r      ,asm"vm.push(vm.pop.to_r)" ;

      ( Data and control stack manipulation words )
      : drop      ,asm"vm.pop" ;
      : dup       ,asm"vm.push(vm.peek)" ;
      : ?dup      ,asm"t=vm.peek; vm.push(t) if t.to_fOOrth_b" ;
      : over      ,asm"vm.push(vm.peek(2))" ;
      : swap      ,asm"b,a = vm.popm(2); vm.push(a); vm.push(b)" ;
      : rot       ,asm"c,b,a = vm.popm(3); vm.push(b); vm.push(a); vm.push(c)" ;
      : pick      ,asm"vm.push(vm.peek(vm.pop))" ;
      : nip       ,asm"b,a = vm.popm(2); vm.push(a)" ;
      : tuck      ,asm"b,a = vm.popm(2); vm.push(a); vm.push(b); vm.push(a)" ;
      : >r        ,asm"vm.ctrl_push(vm.pop) " ;
      : r>        ,asm"vm.push(vm.ctrl_pop) " ;
      : r         ,asm"vm.push(vm.ctrl_peek) " ;
      : rpick     ,asm"vm.push(vm.ctrl_peek(vm.pop))" ;
      : rdrop     ,asm"vm.ctrl_pop " ;

      ( Various "if" control structure words. )
      : if    _se"if"       _<<"if vm.pop? then "                 ;immediate
      : else  -execute"if"  _<<"else "                            ;immediate
      : then  -execute"if"  _<<"end; "                 _re"if"    ;immediate

      ( Various do ... loop control structure words. )
      : do    _se"do"      _<<"vm.vm_do {|i,j| "                  ;immediate
      : i     -execute"do" _<<"vm.push(i[1]); "                   ;immediate
      : j     -execute"do" _<<"vm.push(j[1]); "                   ;immediate
      : -i    -execute"do" _<<"vm.push(i[3]-i[1]); "              ;immediate
      : -j    -execute"do" _<<"vm.push(j[3]-j[1]); "              ;immediate
      : loop  -execute"do" _<<"i[1] += 1}; "           _re"do"    ;immediate
      : +loop -execute"do" _<<"i[1] += vm.pop}; "      _re"do"    ;immediate

      ( Various begin ... until control structure words. )
      : begin _se"begin"      _<<"begin "                         ;immediate
      : while -execute"begin" _<<"break unless pop?; "            ;immediate
      : until -execute"begin" _<<"end until vm.pop?; " _re"begin" ;immediate
      : again -execute"begin" _<<"end until false; "   _re"begin" ;immediate
      "again" alias: repeat

      ( Higher level words that need a more complete dictionary. )      
      : spaces 0 do space loop ;

      ( System utility words. )
      _vm _rv"@vm_version" const: version
      : )version ."fOOrth Version: " version . cr ;
      _vm _av"@debug" ref: debug
      : )debug ."Debug is " debug @ if ."ON" else ."OFF" then cr ;
      : )quit     ,asm"raise ForceExit "  ;
      : )abort    ,asm"vm.abort(')abort') " ;
      : _abort    ,asm"vm.abort(vm.pop) " ;
      "_abort" alias: )abort"
      : ?abort    if )abort"?abort" then ;
      : ?abort"   swap if _abort else drop then ;
      : )start    ,asm"vm.start_time = Time.now " ;
      : )finish   ,asm"puts \"#{Time.now-vm.start_time} elapsed.\"" ;
      : )system   ,asm"system(vm.pop) " ;
      ")system" alias: )"

      ( Vocabulary control )
      : voc_rebuild  ,asm"vm.dictionary.rebuild_cache " ;
      : voc_create"  ,asm"vm.dictionary.create_vocabulary(vm.pop) " ;
      : )current_voc ,asm"puts vm.dictionary.query_current " ;
      : voc_employ"  ,asm"vm.dictionary.install_vocabulary(vm.pop) " ;
      : voc_dismiss" ,asm"vm.dictionary.uninstall_vocabulary(vm.pop) " ;
      : voc_delete"  ,asm"vm.dictionary.delete_vocabulary(vm.pop) " ;
      : )vocs        ,asm"vm.dictionary.list_vocabularies " ;
      : )voc_path    ,asm"vm.dictionary.list_path " ;
      : )all_words   ,asm"vm.dictionary.list_all_words " ;
      : )path_words  ,asm"vm.dictionary.list_path_words " ;
      : )words       ,asm"vm.dictionary.list_words " ;
      END

      @owner.execute_string(fOOrth_src)
    end
  end
end
