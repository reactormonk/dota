class GamePart < Merb::PartController

  def index
    @user = session.user
    @game = Game.first(params[:game])
    @result = @game.result
    @league = @game.league
    @sentinel = @game.sentinel
    @source = @game.scourge
    @type = @game.type
    self.send(StateMapping[@game.state.to_sym])
    render
  end

  StateMapping = {
    :staged => :staged,
    :running => :running,
    :scourge_won => :finished,
    :sentinel_won => :finished,
    :abroted => :finished
  }

  private
  def staged
    if @user
      begin
        @game.allowed_to_join(@user)
      rescue PlayerPlaying
        @join_message = :playing
      rescue NotVouched
        @join_message = :vouched
      rescue Banned
        @join_message = :banned
        @ban = @user.bans(@league).first(:until.desc)
      end
    end
    render :staged
  end

  def running
    render :running
  end

  def finished
    render :finished
  end

end
