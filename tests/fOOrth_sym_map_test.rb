#A formal testing frame for the SymMap class.
#Execute this file to perform the tests.

require_relative '../lib/fOOrth/fOOrth_exceptions'
require_relative '../lib/fOOrth/fOOrth_helper'
require_relative '../lib/fOOrth/fOOrth_sym_map'
require          'minitest/autorun'

class SymMapTester < MiniTest::Unit::TestCase
  #Special initialize to track rake progress.
  def initialize(*all)
    $do_this_only_one_time = "" unless defined? $do_this_only_one_time
    
    if $do_this_only_one_time != __FILE__
      puts
      puts "Running test file: #{File.split(__FILE__)[1]}" 
      $do_this_only_one_time = __FILE__
    end
    
    super(*all)
  end
  
  #Common set up tasks
  def setup
    @s = XfOOrth::SymMap.new
  end

  #Verify mapping and aliasing
  def test_that_symbols_map_correctly
    blk = lambda { 42 }
    x = @s.add_entry('fubar', :word, block: blk)
    z = @s.unmap(x.symbol)

    assert_equal('fubar', x.name)
    assert_equal('fubar', z.name)

    assert_equal(x.symbol, z.symbol)

    assert_equal(:word, x.type)
    assert_equal(:word, z.type)

    refute(x.immediate?)
    refute(z.immediate?)

    assert_equal(42, x.block.call)
    assert_equal(42, z.block.call)
  end
  
  #Verify reverse mapping.
  def test_that_it_can_unmap
    x = @s.add_entry('fubar', :word)
    y = @s.unmap(x.symbol)
    assert_equal(x , y)    
  end

  #Check for a symbol redefine error.
  def test_that_it_catches_redefines
    x = @s.add_entry('fubar', :word)
    assert_raises(XfOOrth::XfOOrthError) { @s.add_entry('fubar', :method) }
  end
  
  #Check for bad option arguments. 
  def test_that_it_rejects_bad_args
    assert_raises(ArgumentError) { y = @s.add_entry(:snafu) }    
    assert_raises(ArgumentError) { y = @s.add_entry('snafu', :word, :instance_method) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :empty, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :local_variable, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :instance_variable, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :global_variable, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :thread_variable, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :thread_variable, :immediate) }
  end
  
  #A test for multiple threads creating symbols.
  def test_that_it_is_thread_safe
    start_syms = ['aaa0000000', 'bbb0000000', 'ccc0000000', 'ddd0000000',
                  'eee0000000', 'fff0000000', 'ggg0000000', 'hhh0000000',
                  'iii0000000', 'jjj0000000', 'kkk0000000', 'lll0000000',
                  'mmm0000000', 'nnn0000000', 'ppp0000000', 'qqq0000000']
    threads = []
    
    start_syms.each do |sym|
      threads << Thread.new(sym) do |x|
        (1000).times do
          @s.add_entry(x, :word)
          x = x.succ
        end
      end  
    end
    
    threads.each {|t| t.join }
    
    assert_equal(@s.fwd_count, @s.rev_count)
  end

end