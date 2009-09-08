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
    unless players.include?(player)
      players << player 
      save
    end
    league_memberships.first(:player => player).vouched = true
    player.save
  end

  def is_vouched?(player)
    !! ((lm = league_memberships.first(:player => player)) && lm.vouched)
  end

  def is_banned?(player)
  end
end
