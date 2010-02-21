BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "LeagueMembershipDecret" do
      suite "AdminDecret" do
        suite "#can_be_issued_by" do
          setup :right, "admin" do
            @right = :admin
          end
          setup :right, "vouched" do
            @right = :vouched
          end
          setup :issuer, "admin" do
            @issuer = :admin
          end
          setup :issuer, "voucher" do
            @issuer = :voucher
          end
          setup :may do
            @may = !(@issuer == :voucher && @right == :admin)
          end
          setup :lm do
            @lm = Factory.lm(@issuer)
            @receiver = Factory(:league_membership, :league => @lm.league)
            @decret = Decret.new(
              :type => "#{@right.capitalize}Decret",
              :issuer => @lm,
              :receiver => @receiver,
              :reason => "foo"
            )
          end
          assert "check if :right may be issued by :issuer" do
            equal(@may, @decret.save)
          end
        end
      end
    end
  end
end
