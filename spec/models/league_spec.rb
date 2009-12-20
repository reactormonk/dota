require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe League do

  it 'should be possible for players to be vouched' do
    league = League.gen
    player = Player.gen
    league.vouch(player)
    league.vouched?(player).should be_true
  end

  it 'should not state a non-vouched player vouched' do
    league = League.gen
    player = Player.gen
    league.vouched?(player).should be_false
  end

  it 'should be possible to ban players' do
    league = League.gen
    player = Player.gen
    league.vouch(player)
    league.ban(player, 2.weeks, "FAIL")
    league.banned?(player).should be_true
    league.bans(player).first.reason.should == "FAIL"
  end

  it 'should not state a non-banned player banned' do
    league = League.gen
    player = Player.gen
    league.vouch(player)
    league.banned?(player).should be_false
    league2 = League.gen
    player2 = Player.gen
    league2.banned?(player2).should be_false
  end

  it 'should not state a player banned if ban is over' do
    league = League.gen
    player = Player.gen
    league.vouch(player)
    league.ban(player, -2.weeks, "FAIL")
    league.banned?(player).should be_false
  end

  describe 'new game' do
    describe 'should create a new game based on type:' do
      before(:each) do
        @players = 5.of {Player.gen}
        @league = League.gen
        @players.each{|p| p.vouch @league}
      end
      it 'RandomGame' do
        (game = @league.new_game("RandomGame", @players.first)).class.should == RandomGame
        @players.first.where_playing.should == game
      end
      it 'CaptainGame' do
        (game = @league.new_game("CaptainGame", @players[1])).class.should == CaptainGame
        @players[1].where_playing.should == game
        (game = @league.new_game("CaptainGame", *@players[2..3])).class.should == CaptainGame
        @players[2..3].each {|p| p.where_playing.should == game}
      end
    end
    describe 'should handle vouching correctly:' do
      it 'if allowed to join'
      it 'if not allowed to join'
    end
  end

end
