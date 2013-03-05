module SimpleUnits
  class Context

    class << self
      def define_unit(name, &block)
        @contexts ||= {}
        @contexts[name.to_s] = new(name, &block) 
      end

      def get_context(name)
        throw :UndefinedUnitError if @contexts[name].nil?
        @contexts[name.to_s]
      end
    end

    attr_accessor :name, :type, :inspector
    def initialize(name=nil, &block)
      @name = name
      yield(self)
    end

  end
end

