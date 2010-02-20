BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "Player" do
      suite "constructors" do
        setup do
          @player = Player.new(:login => "foo")
          2.times {Factory(:league)}
          @player.save
          @player.reload
        end
        assert "league_memberships are created" do
          equal_unordered(League.all, @player.leagues)
        end
      end
    end
  end
end
