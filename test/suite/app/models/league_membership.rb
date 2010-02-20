BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "LeagueMembership" do
      suite "rights" do
        setup :right, "admin" do
          @right = :admin
        end
        setup :right, "voucher" do
          @right = :voucher
        end
        setup :right, "vouched" do
          @right = :vouched
        end
        setup :right, "captain" do
          @right = :captain
        end
        setup :given, "given" do
          @given = true
        end
        setup :given, "not given" do
          @given = false
        end
        setup :decret do
          @lm = Factory(@right)
          decret = @lm.received_decrets.first
          decret.given = @given
          decret.save
          @issuer = decret.issuer
        end
        setup :noise do
          Factory("#{@right}_decret", :receiver => @issuer, :issuer => @lm)
        end
        assert "when :right :given, it should behave correctly." do
          equal(@given, @lm.send("#{@right}?"))
        end
      end
      suite "banned" do
        setup :ban, "still valid ban" do
          @banned = true
        end
        setup :ban, "not valid anymore ban" do
          @banned = false
        end
        setup :decret do
          @lm = Factory(:ban)
          decret = @lm.received_decrets.first
          decret.until = Time.now.send((@banned ? :+ : :-), 60)
          decret.save
        end
        assert "returns the correct boolean based on a :ban" do
          equal(@banned, @lm.banned?)
        end
      end
    end
  end
end
