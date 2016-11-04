#A formal testing frame for the StringSource class.
#Execute this file to perform the tests.

require_relative '../lib/fOOrth/fOOrth_string_source'
require          'minitest/autorun'

class StringSourceTester < MiniTest::Unit::TestCase
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

  #Test StringSource with a simple string.
  def test_that_it_can_source_a_string
    s = XfOOrth::StringSource.new("T123")
    refute(s.eol?)
    refute(s.eof?)
    assert_equal('T', s.get)
    assert_equal('1', s.get)
    assert_equal('2', s.get)
    assert_equal('3', s.get)
    refute(s.eol?)
    refute(s.eof?)
    assert_equal(' ', s.get)
    assert(s.eol?)
    refute(s.eof?)
    
    assert_equal(nil, s.get)
    assert(s.eol?)
    assert(s.eof?)
  end

  #Test StringSource with an array of strings.
  def test_that_it_can_source_an_array_of_strings
    s = XfOOrth::StringSource.new(["T123", "9ABC"])
    refute(s.eol?)
    refute(s.eof?)
    assert_equal('T', s.get)
    assert_equal('1', s.get)
    assert_equal('2', s.get)
    assert_equal('3', s.get)
    refute(s.eol?)
    refute(s.eof?)
    assert_equal(' ', s.get)
    assert(s.eol?)
    refute(s.eof?)

    assert_equal('9', s.get)
    assert_equal('A', s.get)
    assert_equal('B', s.get)
    assert_equal('C', s.get)
    refute(s.eol?)
    refute(s.eof?)
    assert_equal(' ', s.get)
    assert(s.eol?)
    refute(s.eof?)

    assert_equal(nil, s.get)
    assert(s.eol?)
    assert(s.eof?)
  end
end
