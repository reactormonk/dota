require_relative '../spec_helper'

describe "GameMembership" do
  include DotA
  it "should grab the player's score from his LeagueMembership" do
    p,g,l = pgl_vouch
    p.league_memberships.first(:league => l).score = 1200.0
    p.league_memberships.all.each {|mem| mem.save} # Do not ask....
    p.join(g)
    g.game_memberships.first(:player => p).score.should == p.league_memberships.first(:league => l).score
  end

  def pgl_vouch
    l = League.gen
    p = Player.gen
    g = Game.gen
    p.vouch(l)
    [p,g,l]
  end

end
