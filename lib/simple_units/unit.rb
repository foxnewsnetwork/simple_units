module SimpleUnits
  class Unit < Numeric
    class MismatchError < Exception; end
    class UnknownUnitError < Exception; end
    class << self
      def convert_dimension(to_unit, from_unit)
        throw :CannotConvertDimension
      end

      # Not really implemented yet
      def simplify_dimensions(unit)
        unit
      end
    end

    attr_accessor :value, :composite

    def initialize(value, units)
      @value = value
      case units.class.to_s
      when "String", "Symbol"
        @composite = SimpleUnits::Composite.from_string units.to_s
      when "SimpleUnits::Context"
        @composite = SimpleUnits::Composite.from_context units
      when "SimpleUnits::Composite"
        @composite = units
      else
        raise UnknownUnitError.new("#{units} is a #{units.class}")
      end
      
    end

    def units
      composite.to_s
    end

    def to_i
      to_something("i")
    end

    def to_f
      to_something("f")
    end

    def to_something(thing)
      value.send("to_#{thing}")
    end

    def +(other)
      if same_dimension? other
        self.class.new(value + other.value, composite)
      else
        self + SimpleUnits::Unit.convert_dimension(self, other)
      end
    end

    def -(other)
      self + other.opposite
    end

    def *(other)
      case other.class.to_s
      when "Fixnum", "Float", "Integer", "Numeric"
        new_value = value * other
        new_composite = composite
      when "SimpleUnits::Unit"
        new_value = value * other.value
        new_composite = composite * other.composite  
      else
        raise MismatchError.new "#{other} is a #{other.class.to_s}"
      end
      self.class.simplify_dimensions self.class.new(new_value, new_composite)
    end

    def /(other)
      self * other.inverse
    end

    def opposite
      self.class.new(-value, composite)
    end

    def inverse
      self.class.new(1 / value.to_f, composite.inverse)
    end

    def inspect
      if composite.inspector.nil?
        "#{value} #{composite.to_s}"
      else
        composite.inspector.call(value)
      end
    end

    def to_s; inspect; end

    def to_str; to_s; end

    def same_dimension?(other)
      self.composite == other.composite
    end

  end
end