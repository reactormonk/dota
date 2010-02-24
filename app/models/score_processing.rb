module PlayerScore
  def elo(game)
    return false if game.state == "aborted"

    positive_factor = (Rango::AppConfig[:positive_factor])
    negative_factor = (Rango::AppConfig[:negative_factor])

    average = {}
    average[:sentinel] = game.sentinel.inject(0.0) {|sum, player| sum + game.gm(player).score} / game.sentinel.size
    average[:scourge] = game.scourge.inject(0.0) {|sum, player| sum + game.gm(player).score} / game.scourge.size

    elopoints = 1 / ( 1 + 10**((average[:sentinel] - average[:scourge]).abs / 400 ) ) * 40
    score = {}
    game.game_memberships.each do |gm|
      party = gm.party
      gm_score = (average[party] * elopoints) / (gm.score)
      score[gm] = gm_score * (party == game.state.to_sym ? positive_factor : negative_factor) + gm.score
    end
    return score
  end
  extend self
end
