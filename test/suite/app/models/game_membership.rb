BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "GameMembership" do
      suite "validations" do
        setup do
          @league = Factory(:league)
          @player = Factory(:player)
          @lm = LeagueMembership.first(:league => @league, :player => @player)
          @game = Factory(:game, :league => @league)
          @gm = Factory.build(:game_membership, :game => @game, :player => @player)
        end
        suite "generic" do
          suite "not_playing?" do
            setup :gm, "valid" do
              @result = true
            end
            setup :gm, "invalid" do
              game2 = Factory(:game, :league => @league)
              Factory(:game_membership, :game => game2, :player => @player)
              @result = false
            end
            assert ":gm" do
              equal(@result, @gm.save)
            end
          end
          suite "vouched?" do
            setup do
              @league.vouch_required = true
              @league.save
            end
            setup :gm, "valid" do
              Factory(:vouched_decret, :receiver => @lm, :issuer => Factory(:root, :league => @league, :player => Factory(:player)))
              @result = true
            end
            setup :gm, "invalid" do
              @result = false
            end
            assert ":gm" do
              equal(@result, @gm.save)
            end
          end
          suite "not_banned?" do
            setup :gm, "valid" do
              @result = true
            end
            setup :gm, "invalid" do
              Factory(:ban_decret, :receiver => @lm, :issuer => Factory(:root, :league => @league, :player => Factory(:player)))
              @result = false
            end
            assert ":gm" do
              equal(@result, @gm.save)
            end
          end
        end
        suite "CaptainGame" do
        end
      end
    end
  end
end
