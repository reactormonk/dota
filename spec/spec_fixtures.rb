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

GameMembership.fix {{
  :game => Game.pick,
  :player => Player.make,
  :party => proc {[:staged, :scourge, :sentinel].choice}
}}
