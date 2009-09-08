require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe League do

  it 'should be possible for players to be vouched' do
    league = League.gen
    player = Player.gen
    league.vouch(player)
    league.is_vouched?(player).should be_true
    player2 = Player.gen
    league.is_vouched?(player2).should be_false
  end

  it 'should be possible to ban players'

end
