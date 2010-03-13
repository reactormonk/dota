Warden::Manager.serialize_into_session do
  user.id
end

Warden::Manager.serialize_from_session do
  Player.get(id)
end

module Authenticable
  module ClassMethods
  end

  module InstanceMethods
    def ensure_authenticated
      return true if warden.authenticated?(:player)
      warden.authenticate
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

Warden::Strategies.add(:password) do
  def valid?
    params[:login] || params[:password]
  end

  def authenticate!
    return fail! unless user = Player.first(:login => params[:login])

    if user.encrypted_password == params[:password]
      success!(user)
    else
      errors.add(:login, "Username or Password incorrect")
      fail!
    end
  end
end
