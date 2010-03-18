BareTest.suite "DotA" do
  suite "Models" do
    suite "Player" do
      suite "constructors" do
        setup do
          2.times {Factory(:league)}
          @player = Factory(:player)
          @player.reload
        end
        assert "league_memberships are created" do
          equal_unordered(League.all, @player.leagues)
        end
      end
    end
  end
end
