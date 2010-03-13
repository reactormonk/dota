class Factory
  class Proxy #:nodoc:
    class Pick < Build # :nodoc:
      REGISTER = {}
      def initialize(klass)
        @instance = klass.all.reject{|i| REGISTER["#{i.class}#{i.id}"]}.first or raise "No instance of #{klass} found."
        REGISTER["#{@instance.class}#{@instance.id}"] = @instance
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
if defined? Baretest
  BareTest.toplevel_suite.teardown do
    defined?(Factory::Proxy::Pick::REGISTER) && Factory::Proxy::Pick::REGISTER.clear
  end
end
