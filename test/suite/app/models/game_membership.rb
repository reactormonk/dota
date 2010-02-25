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
        suite "leave" do
          setup do
            @game = Factory(:valid_full_game)
            @player = @game.players.sample
          end
          setup :game, "a staged game" do
            @result = true
          end
          suite "checks for game persistence" do
            setup :game, "a running game" do
              @game.start
              @result = false
            end
            assert "a player may or may not leave :game" do
              equal(@result, @player.leave)
            end
          end
          suite "the gm gets destroyed" do
            assert "it's dead" do
              @player.leave
              equal(nil, @player.where_playing)
            end
          end
        end
      end
      suite "RandomGame" do
        suite "distributes every player correctly when joining" do
          setup do
            @game = Factory(:random_game)
          end
          setup :game, "with equal player each side" do
            @player = Factory(:player)
            @parties = [:sentinel, :scourge]
          end
          setup :game, "with more on sentinel" do
            gm = GameMembership.create(:player => Factory(:player), :game => @game)
            gm.party = :sentinel
            gm.save
            @player = Factory(:player)
            @parties = [:scourge]
          end
          setup :game, "with more on scourge" do
            gm = GameMembership.create(:player => Factory(:player), :game => @game)
            gm.party = :scourge
            gm.save
            @player = Factory(:player)
            @parties = [:sentinel]
          end
          setup :exercise do
            @gm = GameMembership.create(:player => @player, :game => @game)
          end
          assert "the correct party gets assigned :game" do
            @parties.include? @gm.party
          end
        end
        suite "CaptainGame" do
        end
      end
    end
  end
end
