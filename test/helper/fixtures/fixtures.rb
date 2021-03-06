ENV['DATAMAPPER'] = "true"
require 'factory_girl'
require_relative 'pick'

Factory.define :player do |p|
  p.sequence(:name) {|n| "name#{n}"}
  p.encrypted_password "sekrit"
end

Factory.define :league do |l|
  l.sequence(:name) {|n| "league#{n}"}
  l.vouch_required false
end

Factory.define :league_membership do |lm|
  lm.association :league
  lm.association :player
end

Factory.define :root, :class => "LeagueMembership" do |lm|
  lm.admin true
end

Factory.define :decret do |d|
  d.reason "Entirely no reason at all."
  d.given true
  d.after_build {|d| Factory(:player); d.issuer = Factory.pick(:root, :league => d.receiver.league)}
end

%w(admin voucher vouched captain).each do |right|
  Factory.define right, :class => "LeagueMembership" do |lm|
    lm.after_build {|lm| Factory("#{right}_decret", :receiver => lm)}
  end
  Factory.define "#{right}_decret", :parent => :decret, :class => "#{right.capitalize}Decret" do |d|
  end
end

Factory.define :ban, :parent => :league_membership do |lm|
  lm.after_build {|lm| Factory(:ban_decret, :receiver => lm)}
end
Factory.define :ban_decret, :parent => :decret, :class => BanDecret do |d|
  d.until Time.now + 3000
end

Factory.define :game_membership do |gm|
end

Factory.define :game do |g|
  g.association :league
  g.mode "ap"
end

Factory.define :random_game, :parent => :game, :class => RandomGame  do |g|
end

Factory.define :full_game, :parent => :game do |g|
  g.after_build do |game|
    10.times {Factory(:game_membership, :game => game, :player => Factory(:player))}
  end
end

Factory.define :valid_full_game, :parent => :full_game do |g|
  g.after_build do |game|
    [[*game.game_memberships], [:sentinel, :scourge]*5].transpose.each {|gm, party|
      gm.party = party
    }
  end
end
