#A formal testing frame for the SymMap class.
#Execute this file to perform the tests.

require_relative '../lib/fOOrth/fOOrth_exceptions'
require_relative '../lib/fOOrth/fOOrth_helper'
require_relative '../lib/fOOrth/fOOrth_context'
require          'minitest/autorun'

class ContextTester < MiniTest::Unit::TestCase  
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
    @c = XfOOrth::Context.new
  end
  
  #Test that it creates working lambda blocks.
  def test_that_it_creates_code
    @c.open('test', :Compile)
    @c << '1 + 2;'
    r = @c.close('test')
    assert_equal(3, r.call())
  end
  
  #Test that it indicates the correct tag on verify.
  def test_that_it_matches_good_tags
    @c.open('test', :Compile)
    assert_equal('test', @c.verify_tag(['rock', 'paper', 'test', 'spock']) )
  end
  
  #Test that it detects mismatched tags.
  def test_that_it_catches_bad_tags
    @c.open('test', :Compile)
    assert_raises(XfOOrth::XfOOrthError) { @c.verify_tag(['rock', 'paper', 'spock']) }    
  end
  
  #Test passing args to the created block.
  def test_that_it_can_pass_args
    @c.open('test', :Compile, prefix: 'lambda {|arg|')
    @c << 'arg + 2;'
    r = @c.close('test')
    assert_equal(3, r.call(1))
  end
  
  #Test depth and info
  def test_some_auxilary_features
    @c.open('test', :Compile)
    assert_equal(1, @c.depth)
    @c.info[:testing] = 1234
    assert_equal(1234, @c.info[:testing])   

    @c[:fubar] = 4321
    assert_equal(4321, @c[:fubar])   
  end
  
  #Testing out improvements to option list 1.1.0
  def test_that_it_catches_missing_modes
    assert_raises(ArgumentError) { @c.open('test') }
  end
  
  #An open is required before verify, close, or unnest.
  def test_that_it_catches_empty_contexts
    assert_raises(XfOOrth::XfOOrthError) { @c.verify_tag(['stuff']) }    
    assert_raises(XfOOrth::XfOOrthError) { @c.close(['stuff'])}    
    assert_raises(XfOOrth::XfOOrthError) { @c.unnest(['stuff'])}    
  end
  
  #An open may not follow an open.
  def test_that_it_catches_bad_nesting_1
    @c.open('test', :Compile)
    assert_raises(XfOOrth::XfOOrthError) { @c.open('test', :Compile) }
  end

  #An open may not follow a nest.
  def test_that_it_catches_bad_nesting_2
    @c.nest('test', :Compile)
    assert_raises(XfOOrth::XfOOrthError) { @c.open('test', :Compile) }
  end
  
  #Test mode tracking in the context.
  def test_that_it_handles_modes
    assert_equal(:Execute, @c.mode)
    @c.open('test', mode: :Compile)
    assert_equal(:Compile, @c.mode)
    @c.nest('[', mode: :Execute)
    assert_equal(:Execute, @c.mode)
    @c.unnest(['['])
    assert_equal(:Compile, @c.mode)
    @c.close(['test'])
    assert_equal(:Execute, @c.mode)
  end
end