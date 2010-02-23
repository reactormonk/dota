BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "GameMembership" do
      suite "validations" do
        setup :lm do
          @league = Factory(:league)
          @player = Factory(:player)
          @lm = LeagueMembership.first(:league => @league, :player => @player)
          @game = Factory(:game, :league => @league)
          @gm = Factory.build(:game_membership, :game => @game, :player => @player)
        end
        suite "generic" do
          suite "playing?" do
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
          end
          suite "banned?" do
          end
        end
        suite "CaptainGame" do
        end
      end
    end
  end
end
