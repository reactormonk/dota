require 'digest/sha1'
Warden::Stategies.add(:foreign_cookie) do

  def valid?
    request.cookies.include?("foreign_id")
  end

  def authenticate!
    unless Digest::SHA1.hexdigest(request.cookies.values_at("foreign_id", "foreign_name").join + ENV['SHARED_SECRET']) == request.cookies["foreign_hash"]
      fail!("Invalid cookie!")
    end
    if player = Player.first(:foreign_id => cookies["foreign_id"])
      player.name = cookies["foreign_name"]
      player.save
    else
      player = Player.create(:foreign_id => cookies["foreign_id"], :name => cookies["foreign_name"])
    end
    success!(player)
  end

end
