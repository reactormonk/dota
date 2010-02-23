class RandomGame < Game
  def random_assignment
    gms = game_memberships.all
    gms.shuffle!
    gms[0..4].each { |gm| gm.party = :sentinel; gm.save}
    gms[5..9].each { |gm| gm.party = :scourge; gm.save}
  end
end
