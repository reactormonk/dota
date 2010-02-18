class LeagueMembership
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :score, Float, :required => true, :default => 1000.0

  # 
  # Associations
  #
  belongs_to :player
  belongs_to :league
  has n, :decrets, :model => "LeagueMembershipDecret"

  def banned?
    !! (decret = decrets.first(:target => self, :type => BanDecret, :until.gt => Time.now)) && decret.given?
  end

  %w(admin vouched voucher captain).each do |type|
    define_method("#{type}?") {
      !! (decret = decrets.first(:target => self, :type => self.class.const_get("#{type.capitalize}Decret"))) && decret.given?
    }
  end
end
