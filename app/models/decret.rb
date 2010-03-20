require 'dm-timestamps'
class Decret
  include DataMapper::Resource

  #
  # Properties
  #
  property :id, Serial
  property :created_at, DateTime
  property :given, Boolean, :required => true, :default => true
  property :reason, String, :required => true
  property :type, Discriminator
  property :until, DateTime

  #
  # Associations
  #
  belongs_to :issuer, :model => "LeagueMembership"
  belongs_to :receiver, :model => "LeagueMembership"

  validates_with_method :receiver, :same_league?, :message => t.decret.cross_league
  validates_with_block :receiver, :message => t.decret.self_reference do |r,p| r.receiver != r.issuer end

  def same_league?
    issuer.league == receiver.league
  end

  def self.can_be_issued_by(role)
    validates_with_block :issuer do
      if issuer.admin? || issuer.send("#{role}?")
        true
      else
        [false, t.decret.cannot_be_issued_by(self.class, role)]
      end
    end
  end
  default_scope(:default).update(:order => [:created_at.desc])
end

class AdminDecret < Decret
  can_be_issued_by :admin
end
class VouchedDecret < Decret
  can_be_issued_by :voucher
end
class VoucherDecret < Decret
  can_be_issued_by :admin
end
class CaptainDecret < Decret
  can_be_issued_by :voucher
end
class BanDecret < Decret
  can_be_issued_by :voucher
  validates_present :until
end
