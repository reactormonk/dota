class LeagueMembership
  include DataMapper::Resource

  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :required => true, :default => 1000.0
  property :admin, Boolean, :default => false

  #
  # Associations
  #
  belongs_to :player
  belongs_to :league

  def issued_decrets
    Decret.all(:issuer => self)
  end

  def received_decrets
    Decret.all(:receiver => self)
  end

  def banned?
    !! (decret = received_decrets.first(:receiver => self, :type => BanDecret, :until.gt => Time.now)) && decret.given
  end

  def admin?
    return true if admin
    !! (decret = received_decrets.first(:receiver => self, :type => AdminDecret)) && decret.given
  end
  %w(vouched voucher captain).each do |type|
    define_method("#{type}?") {
      !! (decret = received_decrets.first(:receiver => self, :type => self.class.const_get("#{type.capitalize}Decret"))) && decret.given
    }
  end
end
