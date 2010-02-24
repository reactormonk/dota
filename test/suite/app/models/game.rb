BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "Game" do
      suite "constructor" do
        setup :game do
          @game = Factory(:game)
        end
        assert "initial state is staged" do
          @game.state == "staged"
        end
      end
      suite "start" do
        setup :game, "a valid game" do
          @game = Factory(:valid_full_game)
          @state = "running"
        end
        setup :game, "a valid game with some players left staged" do
          @game = Factory(:valid_full_game)
          Factory(:game_membership, :game => @game, :player => Factory(:player))
          @state = "running"
        end
        setup :game, "an invalid game (no players set)" do
          @game = Factory(:full_game)
          @state = "staged"
        end
        setup :game, "an invalid game (all in sentinel)" do
          @game = Factory(:valid_full_game)
          @game.game_memberships.each {|p| p.party = :sentinel}
          @state = "staged"
        end
        setup :game, "an invalid game (not enough in scourge)" do
          @game = Factory(:valid_full_game)
          @game.game_memberships(:party => :scourge).sample.party = :staged
          @state = "staged"
        end
        setup :exercise do
          @game.start
        end
        assert "with :game" do
          equal(@state, @game.state)
        end
      end
      suite "stop" do
        setup :game do
          @game = Factory(:valid_full_game)
          @game.start
        end
        suite "votes" do
          setup :votes, "not enough votes to abort" do
            @game.game_memberships.first(6).each {|gm| gm.vote = :abort; gm.save}
            @state = "running"
          end
          setup :votes, "enough votes to abort" do
            @game.game_memberships.first(7).each {|gm| gm.vote = :abort; gm.save}
            @state = "aborted"
          end
          setup :votes, "enough votes for sentinel to win" do
            @game.game_memberships.first(7).each {|gm| gm.vote = ((gm.party == :sentinel) ? :win : :fail); gm.save}
            @state = "sentinel"
          end
          setup :votes, "enough votes for scourge to win" do
            @game.game_memberships.first(7).each {|gm| gm.vote = ((gm.party == :scourge) ? :win : :fail); gm.save}
            @state = "scourge"
          end
          assert "it behaves correctly with :votes" do
            equal(@state, @game.state)
          end
        end
        suite "finish" do
          setup :exercise do
            @game.game_memberships.first(7).each {|gm| gm.vote = ((gm.party == :sentinel) ? :win : :fail); gm.save}
          end
          assert "all players are not considered playing anymore" do
            @game.players.all? {|player| !player.playing?}
          end
          assert "their score is changed" do
            @game.game_memberships.map(&:league_membership).all? {|lm| lm.score != 1000.0}
          end
        end
      end
    end
  end
end
