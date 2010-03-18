BareTest.suite "DotA" do
  suite "integration", :use => :rango_rack_test do
    suite "index actions" do
      setup :page, "/" do
        @page = "/"
      end
      setup :page, "/leagues" do
        @page = "/leagues"
      end
      setup :page, "/players" do
        @page = "/players"
      end
      setup :page, "/" do
        @page = "/games"
      end
      setup :exercise do
        get @page
      end
      assert "response for :page is ok" do
        last_request.ok?
      end
    end
  end
end
