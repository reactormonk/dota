class League
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :irc, String
  property :homepage, String

  # 
  # Associations
  #
  has n, :league_memberships
  has n, :players, :through => :league_memberships
  has n, :games

  def vouch(player)
    mem = league_memberships.first_or_create(:player => player)
    # I don't like this.
    if mem.permissions
      mem.permissions << [:vouched]
    else
      mem.permissions = [:vouched]
    end
    mem.save
  end

  def vouched?(player)
    !! ((mem = lm(player)) and mem.permissions.include?(:vouched))
  end

  def ban(player, secs, reason)
    return false unless vouched?(player)
    ban = LeagueBan.create(:reason => reason, :until => Time.now + secs)
    lm(player).bans << ban
    ban.save
    true
  end

  def banned?(player)
    !! ((lm = lm(player)) && lm.banned?)
  end

  def bans(player)
    if lm = lm(player)
      lm.bans
    else
      false
    end
  end

  private
  def lm(player)
    league_memberships.first(:player => player)
  end
end
