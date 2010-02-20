BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "League" do
      suite "rights" do
        setup do
        end
        suite "#vouched?" do
          setup :vouch do
          end
        end
        suite "#banned?" do
        end
        suite "#captain?" do
        end
        suite "#admin?" do
        end
      end
    end
  end
end
