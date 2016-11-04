require 'option_list'

#Support for an ANSI based character mode console. This is not an international
#based console. It just does ANSI (VT-100) terminal support for a some simple, 
#basic console I/O needs. 
class ANSI_Console
  def self.version
    '0.0.3'
  end
  
  def version
    self.class.version
  end

  #I have NO intention of getting this to work with ancient versions of Ruby.
  if RUBY_VERSION < '1.9.3'
    fail "Ruby version '1.9.3' or greater required. Found '#{RUBY_VERSION}'" 
  end
  
  attr_reader :platform
  attr_reader :version
  attr_reader :found_ANSI
  
  #Install the very lowest level interfaces.
  begin #Connect to the lowest level interface of Windows.
    raise LoadError, "Cygwin is a Posix OS." if RUBY_PLATFORM =~ /\bcygwin\b/i
    raise LoadError, "Not Windows"           if RUBY_PLATFORM !~ /mswin|mingw/  
    require 'Win32API'

    LONG_TIME  = 1.0E9
    SHORT_TIME = 0.1
    POLL_TICK  = 0.04
    SEQ_WAIT   = 0.01
    
    def low_level_init
      @get_key = Win32API.new("msvcrt", "_getch", [], 'I')
      @key_hit = Win32API.new("msvcrt", "_kbhit", [], 'I')
      @platform = "Windows"
      
      #Set up the keyboard mapping hash.
      @mapping = Hash.new
      
      #Map printable characters back to themselves.
      ("\x00".."~").each {|c| @mapping[c] = c}
      
      #Map some non-printable characters as well.
      @mapping["\x00"]     = false
      @mapping["\x08"]     = :backspace
      @mapping["\x09"]     = :tab
      @mapping["\x0A"]     = :new_line
      @mapping["\x0D"]     = :enter
      @mapping["\x1B"]     = :escape
      @mapping["\x7F"]     = :delete
      @mapping["\xE0"]     = false
      
      @mapping["\x00\x3B"] = :pf1
      @mapping["\x00\x3C"] = :pf2
      @mapping["\x00\x3D"] = :pf3
      @mapping["\x00\x3E"] = :pf4
      @mapping["\x00\x3F"] = :pf5
      @mapping["\x00\x40"] = :pf6
      @mapping["\x00\x41"] = :pf7
      @mapping["\x00\x42"] = :pf8
      @mapping["\x00\x43"] = :pf9
      @mapping["\x00\x44"] = :pf10
      @mapping["\xE0\x85"] = :pf11
      @mapping["\xE0\x86"] = :pf12

      @mapping["\x00\x47"] = :home
      @mapping["\x00\x48"] = :up_arrow
      @mapping["\x00\x49"] = :page_up
      @mapping["\x00\x4B"] = :left_arrow
      @mapping["\x00\x4D"] = :right_arrow
      @mapping["\x00\x4F"] = :end
      @mapping["\x00\x50"] = :down_arrow
      @mapping["\x00\x51"] = :page_down
      @mapping["\x00\x52"] = :insert
      @mapping["\x00\x53"] = :delete

      @mapping["\xE0\x47"] = :home
      @mapping["\xE0\x48"] = :up_arrow
      @mapping["\xE0\x49"] = :page_up
      @mapping["\xE0\x4B"] = :left_arrow
      @mapping["\xE0\x4D"] = :right_arrow
      @mapping["\xE0\x4F"] = :end
      @mapping["\xE0\x50"] = :down_arrow
      @mapping["\xE0\x51"] = :page_down
      @mapping["\xE0\x52"] = :insert
      @mapping["\xE0\x53"] = :delete
    end

    def raw_get_char(timeout=LONG_TIME)
      start = Time.now

      while @key_hit.call == 0
        sleep POLL_TICK          
        return '' if (Time.now - start) > timeout
      end

      (@get_key.call).chr    
    end

    def raw_key_hit
      @key_hit.call != 0
    end

    def raw_get_key(timeout=LONG_TIME)
      start, raw_key, result = Time.now, '', nil

      begin
        loop do
          while @key_hit.call == 0
            sleep POLL_TICK          
            return raw_key if (Time.now - start) > timeout
          end

          raw_key << (@get_key.call).chr    
          result = @mapping[raw_key]
          break if result
          raw_key = '' if result.nil?
        end      
      rescue Interrupt
        result = "\x03"
      end

      result
    end

    def raw_flush_keys(timeout=SHORT_TIME)
      start = Time.now

      loop do
        while @key_hit.call == 0
          sleep POLL_TICK          
          return if (Time.now - start) > timeout
        end

        @get_key.call
      end
    end

  rescue LoadError # Handle non-Windows platforms.

    def low_level_init
      @platform = "Other"
      fail "Not written yet dude!"
    end
  end  

  def raw_get_reply(end_char, timeout=LONG_TIME)
    start, result = Time.now, ''
    loop do
      time_left = timeout - (Time.now - start)
      break if time_left <= 0.0
      result << raw_get_char(time_left)
      break if result[-1] == end_char
    end

    result
  end

  def qry_ANSI_status
    raw_flush_keys
    print "\x1B[5n"
    reply = raw_get_reply('n', SHORT_TIME)
    reply == "\x1B[0n"
  end

  def qry_XY
    fail "ANSI not supported." unless @found_ANSI
    raw_flush_keys
    print "\x1B[6n"
    reply = raw_get_reply('R', SHORT_TIME)
    semi = (reply =~ /;/)
    rrrr = (reply =~ /R/)
    [reply[(semi+1)...rrrr].to_i, reply[2...semi].to_i]   
  end

  def goto_XY(x, y)
    fail "ANSI not supported." unless @found_ANSI
    print "\x1B[#{y};#{x}H"
  end

  def bell
    print "\x07"
  end

  def clear_home
    fail "ANSI not supported." unless @found_ANSI
    print "\x1B[2J"
  end

  def clear_line
    fail "ANSI not supported." unless @found_ANSI
    print "\x1B[2K\x1B[G"
  end

  def set_attributes(attr = {})
    first, set_str = true, "\x1B["
    attr.each do |key, value|
      case key
      when :fgnd
        code = ANSI_Console.fgnd[value]
        unless code.nil?
          set_str << ";" unless first
          first = false
          set_str << code
        end
      when :bgnd
        code = ANSI_Console.bgnd[value]
        unless code.nil?
          set_str << ";" unless first
          first = false
          set_str << code
        end
      end
    end
    set_str << "m"
    print set_str
  end

  @fgnd = {:black => '30', :red     => '31', :green => '32', :yellow => '33',
           :blue  => '34', :magenta => '35', :cyan  => '36', :white  => '37'}
  def self.fgnd; @fgnd; end

  @bgnd = {:black => '40', :red     => '41', :green => '42', :yellow => '43',
           :blue  => '44', :magenta => '45', :cyan  => '46', :white  => '47'}

  def self.bgnd; @bgnd; end

  @options = OptionList.new([:check_ANSI, :check_ANSI, :no_check_ANSI],
                            :fgnd => :yellow, :bgnd => :blue)

  def self.options; @options; end

  #Attempt to detect the presence of the ANSI console and
  #set up the default conditions.
  def initialize(*options)
    o = ANSI_Console.options.select(options)
    @closed = false
    low_level_init
    @found_ANSI = o.check_ANSI? && qry_ANSI_status

    if @found_ANSI
      set_attributes(fgnd: o.fgnd, bgnd: o.bgnd)
      ObjectSpace.define_finalizer(self) {close unless @closed}
    end
  end

  def close
    fail "Already closed." if @closed
    set_attributes(fgnd: :yellow, bgnd: :blue)
    clear_home
    @closed = true
  end
end
