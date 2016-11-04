#== fOOrth: an object oriented slant on the classic FORTH language.
#==== fOOrth.rb
#This is the top level file of the fOOrth prototype programming environment.
#This module is spread across several files:
module XfOOrth
  require          'pp'
  require          'getoptlong'
#  require          'curses'
  require_relative 'fOOrth_helper'
  require_relative 'fOOrth_exceptions'
  require_relative 'fOOrth_interpreter'
  require_relative 'fOOrth_word'
  require_relative 'fOOrth_data_ref'
  require_relative 'fOOrth_compiler'
  require_relative 'fOOrth_builds_does'
  require_relative 'fOOrth_dictionary'

  #This class contains the fOOrth virtual machine and its environment.
  class XfOOrthLanguage
    include Interpreter
    include Compiler

    #The (optional) name of the virtual machine instance.
    attr_reader :name

    #This is the main method of the fOOrth language system. It executes
    #any command line code and then executes from the console.
    def XfOOrthLanguage.main
      begin
        fOOrth, first = XfOOrthLanguage.new('main', '00_04_32'), true

        loop do
          begin
            if first
              puts "fOOrth Reference Implementation Version: #{fOOrth.vm_version}"
              fmt = '%Y-%m-%d at %I:%M%P'
              puts "'fOOrth.rb' file date: #{File.stat(__FILE__).mtime.strftime(fmt)}"
              puts "Session began on date: #{Time.now.strftime(fmt)}"

              fOOrth.debug = false         #Force debug OFF by default.
              defer = fOOrth.process_command_line_options
              fOOrth.dictionary.load_fOOrth_kernal
              fOOrth.execute_string(defer)
              puts
              first = false
            end

            fOOrth.execute_console
          rescue ForceAbort => fa
            fOOrth.display_abort(fa)
            break if first
          end
        end
      rescue Interrupt
        puts
        puts "Program interrupted. Exiting fOOrth."
      rescue ForceExit
        puts
        puts "Quit command received. Exiting fOOrth."
      rescue SilentExit
        puts
      rescue Exception => e
        puts
        puts "#{e.class.to_s.gsub(/.*::/, '')} detected: #{e}", e.backtrace
      end
    end

    #Process the command line arguments. A string is returned containing
    #fOOrth commands to be executed after the dictionary is loaded.
    #==== Returns
    #A string of fOOrth commands to be executed after the dictionary is loaded.
    def process_command_line_options
      begin
        defer, found = "", false
        opts = GetoptLong.new(
          [ "--help",  "-h", "-?", GetoptLong::NO_ARGUMENT ],
          [ "--load",  "-l",       GetoptLong::REQUIRED_ARGUMENT ],
          [ "--debug", "-d",       GetoptLong::NO_ARGUMENT ],
          [ "--quit",  "-q",       GetoptLong::NO_ARGUMENT ],
          [ "--words", "-w",       GetoptLong::NO_ARGUMENT ])

        # Process the parsed options
        opts.each do |opt, arg|
          unless found
            puts; found = true
          end

          case opt
          when "--debug"
            @debug = true
          when "--load"
            defer << "load\"#{arg}\" "
          when "--quit"
            defer << ")quit "
          when "--words"
            defer << ")words "
          else
            fail SilentExit
          end
        end

        puts if found
      rescue Exception => e
        puts
        puts "fOOrth available options:"
        puts
        puts "--help  -h  -?          Display this message and exit."
        puts "--load  -l <filename>   Load the specified fOOrth source file."
        puts "--debug -d              Default to debug ON."
        puts "--quit  -q              Quit after processing the command line."
        puts "--words -w              List the current vocabulary."
        puts
        raise SilentExit
      end

      defer
    end

    #Create an new instance of a fOOrth virtual machine
    #==== Parameters:
    #* name - An optional string that describes this virtual machine
    #  instance. This string defaults to '<none>'.
    #* version - The version of this virtual machine. This is ignored if
    #  parent is not nil.
    #* parent - A reference to a parent virtual machine.
    def initialize(name='<none>', version='', parent=nil)
      @name, @vm_version = name, version
      Thread.current[:vm] = self
      @dictionary = Dictionary.new(self, parent && parent.dictionary)
      @vm_version = parent.vm_version unless parent.nil?
      interpreter_reset
      compiler_reset
    end

    #Display the diagnostic data required for a language abort error.
    #==== Parameters:
    #* exception - The exception object that required the system abort.
    def display_abort(exception)
      puts;
      puts exception

      if debug
        puts
        puts "Data Stack Contents:"
        pp data_stack
        puts
        puts "Control Stack Contents:"
        pp ctrl_stack
        puts
        puts "Mode = #{mode.inspect},  Level = #{level}"
      end

      interpreter_reset
      compiler_reset
    end

    #Handling for missing methods of the virtual machine.
    #Fail with an exception.
    #==== Parameters:
    #* name - The name of the missing method.
    #* args - The arguments to that method.
    #* block - Any block argument to that method.
    def method_missing(name, *args, &block)
      fail ForceAbort,
      "The virtual machine '#{@name}' does not implement #{name.inspect}."
    end

    #The fOOrth marker method.
    def fOOrth
    end
  end

  XfOOrthLanguage.main # Get the show on the road!
end
