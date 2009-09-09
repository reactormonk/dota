require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe League do

  it 'should be possible for players to be vouched' do
    league = League.gen
    player = Player.gen
    league.vouch(player)
    league.is_vouched?(player).should be_true
  end

  it 'should not state a non-vouched player vouched' do
    league = League.gen
    player = Player.gen
    league.is_vouched?(player).should be_false
  end

  it 'should be possible to ban players' do
    league = League.gen
    player = Player.gen
    league.vouch(player)
    league.ban(player, 2.weeks, "FAIL")
    league.is_banned?(player).should be_true
    league.bans(player).first.reason.should == "FAIL"
  end

  it 'should not state a non-banned player banned' do
    league = League.gen
    player = Player.gen
    league.vouch(player)
    league.is_banned?(player).should be_false
    league2 = League.gen
    player2 = Player.gen
    league2.is_banned?(player2).should be_false
  end

  it 'should not state a player banned if ban is over' do
    league = League.gen
    player = Player.gen
    league.vouch(player)
    league.ban(player, -2.weeks, "FAIL")
    league.is_banned?(player).should be_false
  end

end
