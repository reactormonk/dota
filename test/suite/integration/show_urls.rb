BareTest.suite "DotA" do
  suite "integration", :use => :rango_rack_test do
    suite "show actions" do
      setup :page, "/leagues/foo without foo" do
        @page = "/leagues/foo"
        @result = 404
      end
      setup :page, "/players/bar without bar" do
        @page = "/players/bar"
        @result = 404
      end
      setup :page, "/games/1 without 1" do
        @page = "/games/1"
        @result = 404
      end
      setup :page, "/leagues/foo" do
        Factory(:league, :name => "foo")
        @page = "/leagues/foo"
        @result = 200
      end
      setup :page, "/players/bar" do
        Factory(:player, :name => "bar")
        @page = "/players/bar"
        @result = 200
      end
      setup :page, "/games/1" do
        Factory(:game, :id => 1)
        @page = "/games/1"
        @result = 200
      end
      setup :exercise do
        get @page
      end
      assert "response for :page" do
        equal(@result, last_response.status)
      end
    end
  end
end
