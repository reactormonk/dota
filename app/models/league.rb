class League
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  property :name, String, :nullable => false, :unique => true
  property :irc, String
  property :homepage, String

  # 
  # Associations
  #
  has n, :league_memberships
  has n, :players, :through => :league_memberships
  has n, :games

  def vouch(player)
    mem = league_memberships.first_or_create(:player => player).vouched = true
  end

  def is_vouched?(player)
    !! ((lm = lm(player)) && lm.vouched)
  end

  def ban(player, secs, reason)
    return false unless is_vouched?(player)
    ban = LeagueBan.create(:reason => reason, :until => Time.now + secs)
    lm(player).bans << ban
    ban.save
    true
  end

  def is_banned?(player)
    !! ((lm = lm(player)) && lm.bans.first(:until.gt => Time.now))
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
