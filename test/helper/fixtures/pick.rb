class Factory
  class Proxy #:nodoc:
    class Pick < Build # :nodoc:
      def initialize(klass)
        @instance = klass.all.reject{|i| i.respond_to? :__picked}.first or raise "No instance of #{klass} found."
        def @instance.__picked
        end
      end
    end
  end
  def self.pick(name, overrides = {})
    factory_by_name(name).run(Proxy::Pick, overrides)
  end
  def self.lm(right)
    Factory.create(:league)
    Factory.create(:player)
    Factory.pick(right)
  end
end
