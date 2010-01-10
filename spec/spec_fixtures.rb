require 'extlib'
require 'dm-sweatshop'
player_fib = Fiber.new do
  n = 0
  loop do
    Fiber.yield({:login => "log#{n}", :qauth => "q#{n}"})
    n +=1
  end
end
league_fib = Fiber.new do
  n = 0
  loop do
    Fiber.yield({:name => "n#{n}"})
    n +=1
  end
end

League.fix {league_fib.resume}

Player.fix {{
  :password => "sekrit",
  :password_confirmation => "sekrit"
}.merge player_fib.resume}

LeagueMembership.fix {{
  :player => Player.make,
  :league => League.pick
}}

Game.fix {{
  :league => League.pick
}}

class Game
  def self.gen_full_game
    league = League.gen
    game = new(:league => league)
    league.save
    game.save
    10.times do
      p = Player.gen
      p.vouch league
      p.join game
    end
    game.game_memberships.reload
    game.players[0..4].each {|p| game.sentinel_set p}
    game.players[5..9].each {|p| game.scourge_set p}
    game.mode = 'ar'
    game.save
    game
  end
end

GameMembership.fix {{
  :game => Game.pick,
  :player => Player.make,
  :party => proc {[:staged, :scourge, :sentinel].choice}
}}
