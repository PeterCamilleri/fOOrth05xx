require_relative 'fOOrth_exceptions'

#Extensions to the \Object class required by the fOOrth language system.
class Object
  #Raise a fOOrth language internal exception as this operation is not allowed.
  def embed
    error "Can't embed class #{self.class.to_s}"
  end

  #Convert this object to a fOOrth boolean.
  def to_fOOrth_b
    self
  end

  #Convert this object to a single character string.
  def to_fOOrth_c
    "\x00"
  end

  #Convert this object to a numeric. Returns nil for fail.
  def to_fOOrth_n
    nil
  end

  #Fail with XfOOrthError argument error.
  def error(msg)
    fail XfOOrth::XfOOrthError, msg, caller
  end

  #Raise an abort exception with message.
  def abort(msg)
    raise XfOOrth::ForceAbort, msg
  end

  alias :read_var  :instance_variable_get
  alias :write_var :instance_variable_set
end

#Extensions to the \Numeric class required by the fOOrth language system.
class Numeric
  #Convert this number to a form suitable for embedding in a source string.
  #==== Returns
  #* An embeddable form of this number as a string.
  def embed
    self.to_s
  end

  #Convert this number to a fOOrth boolean.
  def to_fOOrth_b
    self != 0
  end

  #Convert this number to a single character string.
  def to_fOOrth_c
    self.to_i.chr
  end

  #Convert this numeric to a numeric. Return self.
  def to_fOOrth_n
    self
  end
end

#Extensions to the \Rational class required by the fOOrth language system.
class Rational
  #Convert this rational number to a form suitable for embedding in a source string.
  #==== Returns
  #* An embeddable form of this rational number as a string.
  def embed
    "'#{self.to_s}'.to_r"
  end
end

#Extensions to the \Complex class required by the fOOrth language system.
class Complex
  #Convert this complex number to a form suitable for embedding in a source string.
  #==== Returns
  #* An embeddable form of this complex number as a string.
  def embed
    "Complex(#{self.real.embed},#{self.imaginary.embed})"
  end
end

#Extensions to the \String class required by the fOOrth language system.
class String
  #Convert this String to a form suitable for embedding in a source string.
  #==== Returns
  #* An embeddable form of this string as a string.
  #==== Note:
  #The strings involved go through several layers of quote processing. The
  #resulting code is most entertaining!
  def embed
    "'#{self.gsub(/\\/, "\\\\\\\\").gsub(/'/,  "\\\\'")}'"
  end

  #Convert this string to a fOOrth boolean.
  def to_fOOrth_b
    self != ''
  end

  #Convert this string to a single character string.
  def to_fOOrth_c
    self[0]
  end

  #Convert this string to a numeric. Return a number or nil on fail.
  def to_fOOrth_n
    if /\di$/ =~ self      #Check for a trailing '<digit>i'.
      if /\+/ =~ self      #Check for the internal '+' sign.
        Complex(($`).to_fOOrth_n, ($').chop.to_fOOrth_n)
      else
        Complex(0, self.chop.to_fOOrth_n)
      end
    elsif /\d\/\d/ =~ self #Check for an embedded '<digit>/<digit>'.
      Rational(self)
    elsif /\d\.\d/ =~ self #Check for an embedded '<digit>.<digit>'.
      Float(self)
    else                   #For the rest, assume an integer.
      Integer(self)
    end
  rescue
    nil
  end
end
