class League
  include DataMapper::Resource

  #
  # Properties
  #
  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :irc, String
  property :homepage, String
  property :vouch_required?, Boolean

  # 
  # Associations
  #
  has n, :league_memberships
  has n, :players, :through => :league_memberships
  has n, :games

  def vouched?(player)
    return true unless vouch_required?
    lm(player).vouched?
  end

  %w(banned? captain? admin? voucher?).each do |right|
    define_method(right) {|player|
      lm(player).send(right)
    }
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

  def new_game(type, player, *args)
    case type.downcase.to_sym
    when :randomgame
      new_random_game(player)
    when :captaingame
      new_captain_game(player, args.first)
    else
      raise ArgumentError, "This game type does not exist."
    end
  end

  def new_random_game(player)
    RandomGame.create(:league => self)
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
    league_memberships.first(:player => player)
  end

  before :save, :generate_lm
  def generate_lm
    return true unless new?
    Player.all.each {|player| self.players << player unless self.players.include?(player)}
  end
end
