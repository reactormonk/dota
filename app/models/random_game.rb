class RandomGame < Game
  def randomize_party
    free_parties.sample
  end
end
