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
    end
  end
end
