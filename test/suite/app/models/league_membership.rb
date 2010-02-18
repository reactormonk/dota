BareTest.suite "DotA" do
  suite "Models", :use => :datamapper do
    suite "LeagueMembership" do
      suite "rights" do
        setup do
          @lm = LeagueMembership.gen
        end
        setup :right, "admin" do
          @right  = :admin?
          @decret_class = AdminDecret
        end
        setup :right, "voucher" do
          @right  = :voucher?
          @decret_class = VoucherDecret
        end
        setup :right, "vouched" do
          @right  = :vouched?
          @decret_class = VouchedDecret
        end
        setup :right, "captain" do
          @right  = :captain?
          @decret_class = CaptainDecret
        end
        setup :given, "given" do
          @given = true
        end
        setup :given, "not given" do
          @given = false
        end
        setup :noise do
          @lm.decrets << @decret_class.new(:target => @lm, :given => !@given, :issuer => @lm, :reason => "foo", :created_at => Time.now - 50)
          @lm.decrets << @decret_class.new(:target => LeagueMembership.gen, :given => !@given, :issuer => @lm, :reason => "foo", :created_at => Time.now)
          @lm.decrets << BanDecret.new(:target => LeagueMembership.gen, :issuer => @lm, :reason => "foo", :until => Time.now - 60*30, :created_at => Time.now - 60*30)
          @lm.save!
        end
        setup :decret do
          @lm.decrets << @decret_class.new(:target => @lm, :given => @given, :issuer => @lm, :reason => "foo", :created_at => Time.now)
          @lm.save!
        end
        assert "when :right :given, it should behave correctly." do
          equal(@given,@lm.send(@right))
        end
      end
      suite "banned" do
        setup do
          @lm = LeagueMembership.gen
        end
        setup :ban, "still valid ban" do
          @lm.decrets << BanDecret.new(:target => @lm, :issuer => @lm, :reason => "foo", :until => Time.now + 60*30, :created_at => Time.now - 60*30)
          @banned = true
        end
        setup :ban, "not valid anymore ban" do
          @lm.decrets << BanDecret.new(:target => @lm, :issuer => @lm, :reason => "foo", :until => Time.now - 60*30, :created_at => Time.now - 60*30)
          @banned = false
        end
        setup :noise do
          @lm.decrets << BanDecret.new(:target => LeagueMembership.gen, :issuer => @lm, :reason => "foo", :until => Time.now - 60*30, :created_at => Time.now - 60*30)
          @lm.save!
        end
        setup :save do
          @lm.save!
          @lm.reload
        end
        assert "returns the correct boolean based on a :ban" do
          equal(@banned, @lm.banned?)
        end
      end
    end
  end
end
