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

  # Returns the anonymous challenge to that league (game) or nil
  def pending_challenge
    CaptainGame.all(:state => "challenged").select{|game| game.captains.size == 1}.first
  end

  def anonymous_challenge(challenger)
    captain?(challenger)
    if game = pending_challenge
      game.accept_challenge(challenger)
    else
      game = CaptainGame.anonymous_challenge(self, challenger)
    end
    game
  end

  def direct_challenge(challenger, challenged)
    captain?(challenger)
    captain?(challenged)
    CaptainGame.direct_challenge(self, challenger, challenged)
  end

  # raises NotCaptain if the players is not a captain
  def captain?(player)
    vouched?(player)
    lm(player).captain or raise NotCaptain.new(player, self)
  end

  def new_game(type, player, *args)
    case type.downcase.to_sym
    when :randomgame
      RandomGame.create(:league => self, :players => [player])
    when :captaingame
      if challenged = args.first
        direct_challenge(player, challenged)
      else
        anonymous_challenge(player)
      end
    else
      raise ArgumentError, "This game type doesn not exist."
    end
  end

  private
  def lm(player)
    league_memberships.first(:player => player)
  end
end

class NotAuthorized < StandardError; end
class NotCaptain < NotAuthorized
  def initalize(player, league)
    @player = player
    @league = league
  end
  attr_reader :player, :league
end

class LeagueException < StandardError; end
class NotVouched < LeagueException
  def initialize(player, league)
    @player, @league = player, league
  end
  attr_reader :player, :league
end
class Banned < LeagueException
  def initialize(player, league)
    @player, @league = player, league
  end
  attr_reader :player, :league
end
