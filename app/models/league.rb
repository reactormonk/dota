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
    give_permission(:vouched, player)
  end

  def vouched?(player)
    !! ((mem = lm(player)) and mem.vouched)
  end

  def give_permission(permission, player)
    raise ArgumentError, "#{permission} is not a permission" unless permission?(permission)
    mem = lm(player)
    mem.send("#{permission}=", true)
    mem.save
  end

  def take_permission(permission, player)
    raise ArgumentError, "#{permission} is not a permission" unless permission?(permission)
    mem = lm(player)
    mem.send("#{permission}=", false)
    mem.save
  end

  def permission?(permission)
    [:admin, :voucher, :captain, :vouched].include? permission
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
      new_random_game(player)
    when :captaingame
      new_captain_game(player, args.first)
    else
      raise ArgumentError, "This game type doesn not exist."
    end
  end

  def new_random_game(player)
    game = RandomGame.create(:league => self)
    begin
      game.join player
    rescue => e
      game.destroy
      raise e
    end
    game
  end

  def new_captain_game(challenger, challenged=nil)
    if challenged
      direct_challenge(challenger, challenged)
    else
      anonymous_challenge(challenger)
    end
  end

  private
  def lm(player)
    league_memberships.first_or_create(:player => player)
  end
end

class NotAuthorized < StandardError; end
class NotCaptain < NotAuthorized
  def initialize(player, league)
    @player, @league = player, league
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
