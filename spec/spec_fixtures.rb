require 'dm-sweatshop'
include DataMapper::Sweatshop::Unique
League.fix {{
  :name => /\w{5,15}/.gen
}}

Player.fix {{
  :login => /\w{5,15}/.gen,
  :qauth => /\w{5,15}/.gen,
  :password => "sekrit",
  :password_confirmation => "sekrit"
}}

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
