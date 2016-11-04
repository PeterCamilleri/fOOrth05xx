#A formal testing frame for the fOOrth helper methods.
#Execute this file to perform the tests.

require_relative '../lib/fOOrth/fOOrth_helper'
require          'minitest/autorun'

class HelperTester < MiniTest::Unit::TestCase
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

  #Test all the ways to determine a fOOrth boolean.
  def test_that_to_fOOrth_b_works
    assert(Object.new.to_fOOrth_b)
    assert(:foo.to_fOOrth_b)
    assert(true.to_fOOrth_b)
    refute(false.to_fOOrth_b)
    refute(nil.to_fOOrth_b)

    assert('true'.to_fOOrth_b)
    refute(''.to_fOOrth_b)
    
    assert(1.to_fOOrth_b)
    refute(0.to_fOOrth_b)    

    assert((1.0).to_fOOrth_b)
    refute((0.0).to_fOOrth_b)    

    assert('1/2'.to_r.to_fOOrth_b)
    refute('0/2'.to_r.to_fOOrth_b)
  end

  #Test all the ways to extract a single fOOrth character.
  def test_that_to_fOOrth_c_works
    assert_equal("\x00", Object.new.to_fOOrth_c)
    assert_equal("A", "ABC".to_fOOrth_c)
    assert_equal("A", 65.to_fOOrth_c)
  end

  #Test the ways that values are embedded in code as literals.
  def test_that_embed_works
    assert_equal("65", 65.embed)
    r = '1/2'.to_r
    assert_equal("'1/2'.to_r", r.embed)
    s = "Hello World!"
    assert_equal("'Hello World!'", s.embed,)    
    s = "Pete's \\ing prices!"
    assert_equal("'Pete\\'s \\\\ing prices!'", s.embed,)
    
    c = Complex(1,1)
    assert_equal("Complex(1,1)", c.embed)
    c = Complex(1.23,1)
    assert_equal("Complex(1.23,1)", c.embed)
    c = Complex('1/2'.to_r,1)
    assert_equal("Complex('1/2'.to_r,1)", c.embed)
  end
  
  #Test support for the to_fOOrth_n method
  def test_that_it_supports_to_fOOrth_n
    o = []
    assert_equal(nil, o.to_fOOrth_n)
    assert_equal(42, '42'.to_fOOrth_n)
    assert_equal(42.5, '42.5'.to_fOOrth_n)
    assert_equal('1/3'.to_r, '1/3'.to_fOOrth_n)
    
    assert_equal(Complex(2,2), '2+2i'.to_fOOrth_n)
    assert_equal(Complex(2.5,2), '2.5+2i'.to_fOOrth_n)
    assert_equal(Complex('1/3'.to_r,2), '1/3+2i'.to_fOOrth_n)
    assert_equal(Complex(2,2.5), '2+2.5i'.to_fOOrth_n)
    assert_equal(Complex(2,'1/3'.to_r), '2+1/3i'.to_fOOrth_n)
    assert_equal(Complex(0,2), '2i'.to_fOOrth_n)
    assert_equal(Complex(0,2.5), '2.5i'.to_fOOrth_n)
    assert_equal(Complex(0,'1/3'.to_r), '1/3i'.to_fOOrth_n)
  end

  #Test the quick fail raise in fOOrth.
  def test_that_exceptions_are_easy_to_raise
    assert_raises(XfOOrth::XfOOrthError) { error('Failure IS an option!') }
    assert_raises(XfOOrth::ForceAbort) { abort('Aborting execution!') }    
  end
end
