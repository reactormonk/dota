module PlayerScore
  class << self
    def elo(game)
      return false if game.state == "aborted"

      positive_factor = (Rango::AppConfig[:positive_factor]) 
      negative_factor = (Rango::AppConfig[:negative_factor])

      average = {}
      average[:sentinel] = game.sentinel.inject(0.0) {|sum, player| sum + game.gm(player).score} / game.sentinel.size
      average[:scourge] = game.scourge.inject(0.0) {|sum, player| sum + game.gm(player).score} / game.scourge.size

      elopoints = 1 / ( 1 + 10**((average[:sentinel] - average[:scourge]).abs / 400 ) ) * 40
      score = {}
      game.players.each do |player|
        party = game.party(player)
        player_score = (average[party] * elopoints) / (game.gm(player).score)
        score[player] = player_score * (party == game.result ? positive_factor : negative_factor) + game.gm(player).score
      end
      return score
    end
  end
end
