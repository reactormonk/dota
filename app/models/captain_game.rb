class CaptainGame < Game

  def initialize(*args)
    super
    self.mode = Rango::AppConfig[:captain_game_mode]
  end

  has 2, :captain_memberships, 'GameMembership', :child_key => [ :game_id ], :captain => true
  has 2, :captains, 'Player', :through => :captain_memberships, :via => :player

  #
  # State Machine
  #

  state_machine :initial => :challenged do
    state :challenged

    event :challenge_accepted do
      transition :from => :challenged, :to => :staged
      # add timer
    end

  end

  #
  # Logic
  #
  def self.direct_challenge(league, challenger, challenged)
    game = anonymous_challenge(league, challenger)
    gm_scourge = game.game_memberships.new
    gm_scourge.attributes = {party: :scourge, player: challenged, captain: true}
    game
  end

  def self.anonymous_challenge(league, challenger)
    game = create(:league => league)
    gm_sentinel = game.game_memberships.new
    gm_sentinel.attributes = {party: :sentinel, player: challenger, captain: true}
    game
  end

  def pick(capt, player)
    gm = gm(player)
    gm.party = pick_next
    gm.picked = true
  end
end
