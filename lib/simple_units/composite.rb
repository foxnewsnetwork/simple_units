module SimpleUnits
  class Composite

    class << self
      def from_context(context)
        new.tap do |composite|
          composite.append_numerators! context
        end
      end

      def from_string(string)
        from_context SimpleUnits::Context.get_context string
      end
    end

    def append_numerators!(*contexts)
      contexts.each { |context| append_numerator! context }
      simplify!
    end

    def append_denominators!(*contexts)
      contexts.each { |context| append_denominator! context }
      simplify!
    end

    def append_numerator!(context)
      modify_context_by_order!(context, 1)
    end

    def append_denominator!(context)
      modify_context_by_order!(context, -1)
    end

    def modify_context_by_order!(context, order)
      @contexts_hash ||= {}
      if @contexts_hash[context.name.to_s].nil? 
        @contexts_hash[context.name.to_s] = { :context => context, :order => order }
      else
        @contexts_hash[context.name.to_s][:order] += order
      end
    end


    def numerators
      @contexts_hash.reject do |name, hash|
        hash[:order] < 0
      end
    end

    def denominators
      @contexts_hash.reject do |name, hash|
        hash[:order] > 0
      end
    end


    def inverse
      self.class.new.tap do |composite|
        (numerators.to_a + denominators.to_a).each { |name, hash| composite.modify_context_by_order!(hash[:context], -hash[:order]) }
        composite.simplify!
      end
    end

    def simplify!
      @contexts_hash.reject! do |name, hash|
        hash[:order].zero?
      end
    end

    def inspector
      if @contexts_hash.keys.count == 1 
        @contexts_hash[@contexts_hash.keys.first][:context].inspector
      end
    end

    def to_str
      @contexts_hash.to_a.sort { |a,b| a.first <=> b.first }.inject("") do |str, package|
        order = package.last[:order]
        name = package.first
        str + "(#{name}^#{order})"
      end.gsub("^1", "")
    end

    def to_s; to_str; end

    def *(other)
      array = other.denominators.to_a + self.denominators.to_a + other.numerators.to_a + self.numerators.to_a
      self.class.new.tap do |composite|
        array.each do |name, hash|
          composite.modify_context_by_order!(hash[:context], hash[:order])
        end
        composite.simplify!
      end
    end

    def ==(other)
      to_str == other.to_str
    end

  end
end