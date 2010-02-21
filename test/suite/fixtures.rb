BareTest.suite "DotA" do
  suite "fixtures", :use => :datamapper do
    suite "#lm" do
      setup do
        Factory.lm(:admin)
      end
      assert "generates two LM (one root and one that's admin)" do
        equal(2, LeagueMembership.all.count)
      end
    end
    suite "root" do
      setup do
        Factory.lm(:root)
      end
      assert "generates only one LM" do
        equal(1, LeagueMembership.all.count)
      end
    end
  end
end
