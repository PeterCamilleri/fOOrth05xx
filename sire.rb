# Really simple program # 3
# A Simple Interactive Ruby Environment
# SIRE fOOrth Testing.

require_relative 'lib/fOOrth/fOOrth_object'
require_relative 'lib/fOOrth/fOOrth_class'

require 'readline'
require 'prime.rb'
require 'pp'
include Readline

class Object 
  def classes
    begin
      klass = self
      
      begin
        klass = klass.class unless klass.instance_of?(Class)
        print klass
        klass = klass.superclass
        print " < " if klass
      end while klass
      
      puts
    end
  end
end

def bench(count=1000000, &block)
   puts
   puts 'Starting benchmark test.'
   start = Time.now
   
   count.times { block.call }
   
   elapsed = Time.now - start
   puts "Elapsed time = #{elapsed}"
end

XfOOrth::XfOOrthClass.initialize_classes

@a = XfOOrth::XfOOrthClass.object_class
@b = $all_classes

@c = @b['Object']
@d = @b['Class']

@e = @c.create_fOOrth_instance(nil) #I don't have a vm object to pass in yet!

@f = @c.create_fOOrth_subclass(nil, 'MyClass')
@g = @f.create_fOOrth_instance(nil)

puts
puts "Welcome to the SIRE fOOrth Test Bed."
puts "Simple Interactive Ruby Environment"
puts
puts "#{__FILE__} #{File.split(__FILE__)[1]}"
puts "#{$0} #{File.split($0)[1]}"
puts (File.split(__FILE__)[1]) == (File.split($0)[1])
puts
done = false

until done
  begin
    line = readline('SIRE>', true)
    
    unless line == ''
      result = eval line
      print 'result => '
      pp result
    end
  rescue Interrupt
    done = true
  rescue Exception => e
    puts "#{e.class} detected: #{e}", e.backtrace
    puts
  end
end

puts
puts "Bye bye for now!"