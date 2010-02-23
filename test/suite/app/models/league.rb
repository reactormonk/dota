BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "League" do
      suite "rights" do
        setup :lm, "admin" do
          @right = :admin
        end
        setup :lm, "voucher" do
          @right = :voucher
        end
        setup :given, "given" do
          @given = true
        end
        setup :given, "not given" do
          @given = false
        end
        setup :league do
          @lm = Factory.lm @right
          @league = @lm.league
          @player = @lm.player
          decret = @lm.received_decrets.first
          decret.given = @given
          decret.save
        end
        assert "if the rights for :lm are :given, it should respond adequate" do
          equal(@given, @league.send("#{@right}?", @player))
        end
      end
      suite "constructors" do
        setup do
          2.times {Factory(:player)}
          @league = Factory(:league)
          @league.reload
        end
        assert "league_memberships are created" do
          equal_unordered(Player.all, @league.players)
        end
      end
    end
  end
end
