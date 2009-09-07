require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Game do

  describe 'stage' do

    it 'should be created associated to a league'

    it 'should be possible for players to join'

    describe 'should not allow a player to join if' do
      
      it "he's banned"

      it "he's not vouched"

      it "he's playing already"

    end

    it 'should be possible to set a mode'

    describe 'various player distribution mechanism' do

      it 'should implement captains'

      it 'should implement (intelligent) random assignment'

    end

    it "should grab the player's score from his LeagueMembership"

    it 'should be destroyed if the last player left the game'

    it 'should be destroyable even with players staged/assigned'

  end

  describe 'start' do

    it 'should start only with 5 players each'

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
