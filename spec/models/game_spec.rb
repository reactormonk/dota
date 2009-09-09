require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Game do
  before(:all) do
    League.gen
  end

  describe 'stage' do

    it 'should be created associated to a league' do
      Game.gen.league.class.should == League
    end

    it 'should be possible for players to join' do
      p = Player.gen
      g = Game.gen
      p.join(g).should be_true # @g.join(@p) possible too
      g.players.all.include?(p).should be_true
      p.where_playing.should == g
    end

    it 'should be possible for players to leave' do
      p = Player.gen
      g = Game.gen
      p.join(g).should be_true
      p.leave.should be_true
      g.reload
      g.players.all.include?(p).should be_false
      p.is_playing?.should be_false
    end

    describe 'should not allow a player to join if' do
      
      it "he's banned"

      it "he's not vouched"

      it "he's playing already"

    end

    it 'should be possible to set a mode' do
      g = Game.gen
      g.mode = "ar"
      g.mode.should == "ar"
    end

    describe 'various player distribution mechanism' do

      it 'should implement captains'

      it 'should implement (intelligent) random assignment'

    end

    it "should grab the player's score from his LeagueMembership"

    it 'should be destroyed if the last player left the game'

    it 'should be destroyable even with players staged/assigned'

  end

  describe 'start' do

    it 'should start only with 5 players each and a mode set'

    it 'should set start_time'

    it 'should not allow joining/leaving players'

    it 'should drop staged (not-assigned) players'

  end

  describe 'end' do

    describe 'accept votes' do

      it 'should be possible to abort the game'

      it 'should be possible for sentinel/scourge to win the game'

    end
    
    it 'should only finish with a replay [magic file check?]'

  end

end
