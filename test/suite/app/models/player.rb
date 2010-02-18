BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "Player" do
      suite "constructors" do
        setup do
          @player = Player.new(:login => "foo")
          @leagues = 2.of {League.gen}
          @player.save
          @player.reload
        end
        assert "league_memberships are created" do
          equal(2,@player.leagues.size)
        end
      end
    end
  end
end
