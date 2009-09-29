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
        proc {p.join(g)}.should raise_error Banned
      end

      it "he's not vouched" do
        p = Player.gen
        g = Game.gen
        l = g.league
        proc { p.join(g)}.should raise_error NotVouched
      end

      it "he's playing already" do
        p,g,l = pgl_vouch
        p.join(g)
        g2 = Game.gen(:league => l)
        proc {p.join(g2)}.should raise_error PlayerPlaying
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
          l,players,game = capt_lpg
          game.players.all.size.should == 2
          Set.new([game.gm(players[0]).party, game.gm(players[1]).party]).should == Set.new([:scourge, :sentinel])
        end

        describe 'should not allow an already playing captain' do
          it 'to challenge' do
            league = League.pick
            players = 2.of{Player.gen}
            players.each {|p| league.vouch p}
            game = Game.gen(:league => league)
            game.join(players.first).should be_true
            players.first.is_playing?.should be_true
            proc {players.first.challenge(league, players[1])}.should raise_error PlayerPlaying
            players[1].is_playing?.should be_false
          end

          it 'to be challenged' do
            league = League.pick
            players = 2.of{Player.gen}
            players.each {|p| league.vouch p}
            game = Game.gen(:league => league)
            game.join(players.first).should be_true
            players.first.is_playing?.should be_true
            proc {players[1].challenge(league, players.first)}.should raise_error PlayerPlaying
          end
        end

        describe 'should accept a challenge' do
          it '[direct]' do
            league = League.pick
            players = 2.of {Player.gen}
            players.each {|p| league.vouch p}
            captain_game = players.first.challenge(league, players[1])
            captain_game.reload
            players[1].challenged?.should be_true
            captain_game.captains.size.should == 2
          end
        end

        describe 'should accept a challenge' do
          it '[anonymous]' do
            league = League.gen
            players = 2.of {Player.gen}
            players.each {|p| league.vouch p}
            players.first.is_vouched?(league).should be_true
            players.first.challenge(league)
            captain_game = CaptainGame.first(:league => league)
            players.first.challenged?.should be_true
            players[1].challenge(league)
            captain_game.captains.size.should == 2
            captain_game.captains.should include players[1]
          end
        end

        describe 'should destroy / transitiate depending on reaction:' do
          it 'reject' do
            league = League.gen
            players = 2.of {Player.gen}
            players.each {|p| league.vouch p}
            players.first.challenge(league, players[1])
            players.last.is_playing?.should be_true
            players.last.leave
            players.first.is_playing?.should be_false
            players.last.is_playing?.should be_false
          end
        end

        it 'should not be possible for players to join a challenge not yet accepted'

        it 'should be able to pick' do
          l, players, game = capt_lpg
          proc {game.pick(game.picking_captain, players[2])}.should raise_error PlayerNotJoined
          game.join(players[2]).should be_true
          game.reload
          proc {game.pick(game.picking_captain, players[2])}.should_not raise_error
          game.reload
          players[2].reload
          proc {game.pick(game.picking_captain, players[2])}.should raise_error AlreadyPicked
          players[3..4].each {|p| p.join(game)}
          game.reload
          proc {game.pick(game.picking_captain, players[3])}.should_not raise_error
          game.reload
          proc {game.pick((game.captains.all - [game.picking_captain]).first, players[4])}.should raise_error NotYourTurn
        end

        it 'should be able to repick after a leave' do
          l, players, game = capt_lpg
          players[2..4].each {|p| p.join(game)}
          game.reload
          proc {game.pick(game.picking_captain, players[2])}.should_not raise_error
          game.reload
          proc {game.pick(game.picking_captain, players[3])}.should_not raise_error
          # Now both should have 2 players
          game.reload
          players[3].reload
          [:sentinel, :scourge].include?(party = players[3].party).should be_true
          players[3].leave
          game.pick_next.should == party
        end

        it 'should start with 5 players each'

        def capt_lpg
          l = League.pick
          players = 5.of {Player.gen}
          players.each {|p| p.vouch(l)}
          game = CaptainGame.gen(:league => l)
          players[0..1].each {|p| game.join_as_captain(p)}
          game.distribute_captains
          game.reload
          [l,players,game]
        end
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
      p.league_memberships.all.each {|mem| mem.save} # Do not ask....
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
