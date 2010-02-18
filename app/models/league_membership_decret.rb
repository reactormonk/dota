require 'dm-timestamps'
class LeagueMembershipDecret
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :created_at, DateTime
  property :given?, Boolean, :required => true, :default => true
  property :reason, String, :required => true
  property :type, Discriminator
  property :until, DateTime

  #
  # Associations
  #
  belongs_to :issuer, :model => "LeagueMembership"
  belongs_to :target, :model => "LeagueMembership"

  def self.can_be_issued_by(role)
    validates_with_block(:issuer, :message => "is not allowed to issue a decret, must be at least #{role}.") {|decret| decret.issuer.send("#{role}?")}
  end
  default_scope(:default).update(:order => [:created_at.desc])
end

class AdminDecret < LeagueMembershipDecret
  can_be_issued_by :admin
end
class VouchedDecret < LeagueMembershipDecret
  can_be_issued_by :voucher
end
class VoucherDecret < LeagueMembershipDecret
  can_be_issued_by :admin
end
class CaptainDecret < LeagueMembershipDecret
  can_be_issued_by :admin
end
class BanDecret < LeagueMembershipDecret
  can_be_issued_by :voucher
  validates_present :until
end
