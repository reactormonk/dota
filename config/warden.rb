require 'warden'
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
    !! params['player']['name'] || params['player']['password']
  end

  def authenticate!
    return fail! unless user = Player.first(:name => params['player']['name'])

    if user.encrypted_password == params['player']['password']
      success!(user)
    else
      fail!
    end
  end
end
