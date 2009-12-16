require 'set'

describe "Game" do
  include DotA
  before(:all) do
    $DEBUG = false
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
      p2 = Player.gen
      p2.vouch l
      p.join(g).should be_true
      p2.join g
      p.leave.should be_true
      g.reload
      g.players.all.include?(p).should be_false
      p.playing?.should be_false
    end

    it 'should be possible to rejoin' do
      p,g,l = pgl_vouch
      p2 = Player.gen
      p2.vouch l
      p.join(g).should be_true
      p2.join(g).should be_true
      g.reload
      p.leave
      g.reload
      g.players.all.include?(p).should be_false
      g.join(p).should be_true
      g.reload
      g.players.all.include?(p).should be_true
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
            players.first.playing?.should be_true
            proc {players.first.challenge(league, players[1])}.should raise_error PlayerPlaying
            players[1].playing?.should be_false
          end

          it 'to be challenged' do
            league = League.pick
            players = 2.of{Player.gen}
            players.each {|p| league.vouch p}
            game = Game.gen(:league => league)
            game.join(players.first).should be_true
            players.first.playing?.should be_true
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
            players.first.vouched?(league).should be_true
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
            players.last.playing?.should be_true
            players.last.leave
            players.each {|p| p.playing?.should be_false}
          end

          it 'accept' do
            league = League.gen
            players = 2.of {Player.gen}
            players.each {|p| league.vouch p}
            captain_game = players.first.challenge(league, players.last)
            captain_game.save
            players.last.accept_challenge
            players.each {|p| p.playing?.should be_true}
            Set.new(captain_game.captains).should == Set.new(players)
            captain_game.reload
            captain_game.state.should == "staged"
          end
        end

        it 'should not be possible for players to join a challenge not yet accepted' do
          league = League.gen
          players = 2.of{Player.gen}
          players.each {|p| league.vouch p}
          captain_game = players.first.challenge league
          proc {players.last.join captain_game}.should raise_error ChallengeNotAccepted
        end

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
          proc {game.pick(game.captains.all.reject{|capt| capt == game.picking_captain}.first, players[4])}.should raise_error NotYourTurn
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
          game.reload
          game.pick_next.should == party
        end

        it 'should apply choose_pick_next fair' do
          l, players, game = capt_lpg
          players[2..4].each {|p| p.join(game)}
          game.reload
          game.sentinel_set(players[2])
          game.choose_pick_next.should == :scourge
          players[3..4].each {|player| game.scourge_set(player)}
          game.choose_pick_next.should == :sentinel
          players[3..4].each {|player| game.sentinel_set(player)}
          game.choose_pick_next.should == :scourge
        end

        it 'should start with 5 players each' do
          l, players, game = capt_lpg
          game.state.should == "staged"
          players.concat 5.of {p = Player.gen; l.vouch p; p}
          players[2..9].each do |player|
            player.join game
            game.game_memberships.reload
            game.reload
            game.pick(game.picking_captain, player)
          end
          game.state.should == "running"
        end

        def capt_lpg
          l = League.pick
          players = 5.of {Player.gen}
          players.each {|p| p.vouch(l)}
          players[0].challenge(l,players[1])
          players[1].accept_challenge
          game = players[0].games.first
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
        g.reload
        g.random_assignment.should be_true
        g.sentinel.size.should == 5
        g.scourge.size.should == 5
      end

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

    it 'should start only with 5 players each and a mode set' do
      game = Game.gen_full_game
      game.save.should be_true
      player = Player.gen
      player.vouch(game.league)
      player.join game
      game.game_memberships.reload
      game.party_set(player, :sentinel)
      game.start.should be_false
      player.leave.should be_true
      GameMembership.all.reload
      left_player = [game.players.first, game.players.first.party]
      left_player.first.leave
      game.save.should be_true
      game.reload
      game.start.should be_false
      left_player.first.join(game).should be_true
      game.game_memberships.reload
      game.party_set(*left_player)
      game.enough_players.first.should be_true
      game.mode = nil
      game.start.should be_false
      game.mode = 'ar'
      game.save
      game.start.should be_true
    end

    it 'should set start_time' do
      game = Game.gen_full_game
      game.start
      game.start_time.class.should == DateTime
    end

    it 'should not allow joining/leaving players' do
      game = Game.gen_full_game
      game.start
      player1 = game.players.first
      proc{game.players.first.leave}.should raise_error GameRunning
      game.reload
      player1.playing?.should be_true
      game.save.should be_true
      player = Player.gen
      proc{game.join player}.should raise_error GameRunning
      player.playing?.should be_false
    end

    it 'should drop staged (not-assigned) players' do
      game = Game.gen_full_game
      players = 5.of {Player.gen}
      players.each do |player|
        player.vouch game.league
        player.join game
      end
      game.game_memberships.reload
      game.start
      players.each do |player|
        player.playing?.should be_false
      end
    end

  end

  describe 'end' do

    describe 'processing votes' do

      it "should accept vouches" do
        game = Game.gen_full_game
        game.start
        game.players.first.vote :abort
        game.game_memberships.reload
        game.votes[:abort].should == 1
      end

      it 'should be possible to abort the game' do
        game = Game.gen_full_game
        players = game.players
        game.start
        game.players[0..6].each {|p| p.vote :abort}
        game.reload
        game.state.should == "aborted"
        players.each {|p| p.playing?.should be_false}
      end

      it 'should be possible for sentinel/scourge to win the game' do
        game = Game.gen_full_game
        players = game.players
        game.start
        game.players[0..6].each {|p| p.vote :sentinel_wins}
        game.reload
        game.state.should == "sentinel_won"
        players.each {|p| p.playing?.should be_false}
      end

    end

    it 'should process score and write it to the LeagueMembership' do
      game = Game.gen_full_game
      players = game.players
      game.start
      game.sentinel_wins
      game.result.should == :sentinel
      players.each {|p| p.score(game.league).should_not == 1000.0}
    end
    
    it 'should only finish with a replay [magic file check?]'

  end

end
