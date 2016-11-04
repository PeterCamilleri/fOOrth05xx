#A formal testing frame for the SymMap class.
#Execute this file to perform the tests.

require_relative '../lib/fOOrth/fOOrth_exceptions'
require_relative '../lib/fOOrth/fOOrth_helper'
require_relative '../lib/fOOrth/fOOrth_sym_entry'
require          'minitest/autorun'

class SymEntryTester < MiniTest::Unit::TestCase
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

  #A very simple test of a very simple class.
  def test_that_it_holds_data_correctly
    t = XfOOrth::SymEntry.new('test', :aa0001, :method, false) { 42 }
    
    assert_equal('test', t.name)
    assert_equal(:aa0001, t.symbol)
    assert_equal(:method, t.type)
    refute(t.immediate?)
    assert_equal(42, t.block.call)    
  end
end