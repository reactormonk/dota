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
    # I don't like this.
    mem = league_memberships.first_or_create(:player => player)
    mem.vouched = true
    mem.save
  end

  def is_vouched?(player)
    !! ((mem = lm(player)) && mem.vouched)
  end

  def ban(player, secs, reason)
    return false unless is_vouched?(player)
    ban = LeagueBan.create(:reason => reason, :until => Time.now + secs)
    lm(player).bans << ban
    ban.save
    true
  end

  def is_banned?(player)
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
