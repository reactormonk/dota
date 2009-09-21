require File.join( File.dirname(__FILE__), '..', "spec_helper" )
require 'set'

describe Game do
  before(:all) do
    League.gen
  end

  describe 'stage' do

    it 'should be created associated to a league' do
      Game.gen.league.class.should == League
    end

    it 'should be possible for players to join' do
      p,g,l = pgl_vouch
      p.join(g).should be_true # @g.join(@p) possible too
      g.players.all.include?(p).should be_true
      p.where_playing.should == g
    end

    it 'should be possible for players to leave' do
      p,g,l = pgl_vouch
      p.join(g).should be_true
      p.leave.should be_true
      g.reload
      g.players.all.include?(p).should be_false
      p.is_playing?.should be_false
    end

    describe 'should not allow a player to join if' do
      
      it "he's banned" do
        p,g,l = pgl_vouch
        p.ban(l, 2.weeks, "FAIL")
        p.join(g).should be_false
      end

      it "he's not vouched" do
        p = Player.gen
        g = Game.gen
        l = g.league
        p.join(g).should be_false
      end

      it "he's playing already" do
        p,g,l = pgl_vouch
        p.join(g)
        g2 = Game.gen
        p.join(g2).should be_false
      end

    end

    it 'should be possible to set a mode' do
      g = Game.gen
      g.mode = "ar"
      g.mode.should == "ar"
    end

    describe 'various player distribution mechanism:' do

      describe 'captains' do

        it 'should be assigned' do
          l = League.pick
          players = 5.of {Player.gen}
          players.each {|p| p.vouch(l)}
          game = CaptainGame.gen(:captains => players[0..1])
          game.reload
          game.distribute_captains
          game.players.all.size.should == 2
          Set.new([game.gm(players[0]).party, game.gm(players[1]).party]).should == Set.new([:scourge, :sentinel])
        end

        it 'should be able to pick'

        it 'should be able to repick after a leave'

        it 'should start with 5 players each'

      end

      it '(intelligent) random assignment' do
        # Not intelligent yet :)
        l = League.gen
        ps = 12.of {Player.gen}
        ps.each {|p| p.vouch l}
        g = RandomGame.gen(:league => l)
        ps.each {|p| p.join(g).should be_true}
        g.random_assignment.should be_true
        g.sentinel.size.should == 5
        g.scourge.size.should == 5
      end

    end

    it "should grab the player's score from his LeagueMembership" do
      p,g,l = pgl_vouch
      p.league_memberships.first(:league => l).score = 1200.0
      p.join(g)
      g.game_memberships.first(:player => p).score.should == p.league_memberships.first(:league => l).score
    end

    it 'should be destroyed if the last player left the game' do
      p,g,l = pgl_vouch
      p.join(g)
      p.leave
      id = g.id
      Game.get(id).should be_nil
    end

    def pgl_vouch
      p = Player.gen
      g = Game.gen
      l = g.league
      p.vouch(l)
      [p,g,l]
    end

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
