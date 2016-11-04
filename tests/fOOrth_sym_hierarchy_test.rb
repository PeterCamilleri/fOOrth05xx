#A formal testing frame for the SymMap class.
#Execute this file to perform the tests.

require_relative '../lib/fOOrth/fOOrth_exceptions'
require_relative '../lib/fOOrth/fOOrth_helper'
require_relative '../lib/fOOrth/fOOrth_sym_map'
require_relative '../lib/fOOrth/fOOrth_sym_hierarchy'
require          'minitest/autorun'

class SymHierarchyTester < MiniTest::Unit::TestCase
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
  
  #Common setup tasks
  def setup
    @t = XfOOrth::SymMap.new
    @s = XfOOrth::SymHierarchy.new(@t)
  end

  #Are symbols added?
  def test_that_sym_tabs_can_add_symbols
    x = @s.add_entry('fubar', :word)
    assert_equal(:word, x.type)
    assert_equal(false, x.immediate?)
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
    assert_raises(XfOOrth::XfOOrthError) { @s.add_entry('fubar', :word, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { @s.add_entry('fubar', :method, :immediate) }
  end
  
  #Check for bad option arguments. 
  def test_that_it_rejects_bad_args
    assert_raises(ArgumentError) { y = @s.add_entry(:snafu) }    
    assert_raises(ArgumentError) { y = @s.add_entry('snafu', :word, :instance_method) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :empty, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :local_variable, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :instance_variable, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :thread_variable, :immediate) }
    assert_raises(XfOOrth::XfOOrthError) { y = @s.add_entry('snafu', :global_variable, :immediate) }
  end
end
