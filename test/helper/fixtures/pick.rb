class Factory
  class Proxy #:nodoc:
    class Pick < Create # :nodoc:
      def initialize(klass)
        @instance = klass.all.sample or raise "No instance of #{klass} found."
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
