# encoding: utf-8

# === Usage === #
# Run gem bundle for installation. You have to have bundler gem installed.

# http://github.com/wycats/bundler
# http://litanyagainstfear.com/blog/2009/10/14/gem-bundler-is-the-future
# http://yehudakatz.com/2009/11/03/using-the-new-gem-bundler-today
# http://www.engineyard.com/blog/2009/using-the-rubygems-bundler-for-your-app
source :gemcutter

# === Shared Gems === #
# Specify a dependency on rango. When the bundler downloads gems,
# it will download rango as well as all of rango' dependencies
gem "rango", git: "git://github.com/botanicus/rango.git"
gem "rack"#, git: "git://github.com/rack/rack.git"
gem "rubyexts"
gem "media-path"

# router
gem "usher"#, git: "git://github.com/joshbuddy/usher.git"
gem "crudtree"#, git: "git://github.com/Tass/CRUDtree.git"

# template engine
gem "haml"#, git: "git://github.com/nex3/haml.git"
gem "tilt"
gem "styler", git: "git://github.com/Tass/styler.git"

# ORM
gem "data_objects"
gem "dm-core", git: "git://github.com/datamapper/dm-core.git"
gem "dm-timestamps", git: "git://github.com/Tass/dm-more.git"
gem "dm-types", git: "git://github.com/Tass/dm-more.git"
gem "dm-validations", git: "git://github.com/Tass/dm-more.git"
gem "dm-aggregates", git: "git://github.com/Tass/dm-more.git" # for count etc

gem "state_machine", git: "git://github.com/pluginaweek/state_machine.git"

# auth
gem "bcrypt-ruby"
gem "warden"
gem "bureaucrat"

gem "nake"
gem "simple-logger"

# === Environment-Specific Setup === #
group(:development) do
  gem "shotgun", require: nil#, git: "git://github.com/rtomayko/shotgun.git"
  gem "thin", require: nil#, git: "git://github.com/macournoyer/thin.git" # there seems to be some problems with latest thin
  #gem "unicorn", require: nil#, git: "git://repo.or.cz/unicorn.git"
  gem "racksh", require: nil#, git: "git://github.com/sickill/racksh.git"
end

group(:development, :test) do
  gem "do_sqlite3"#, git: "git://github.com/datamapper/do.git"
  gem "activesupport"
  gem "dm-factory_girl", git: "git://github.com/Tass/factory_girl.git", :require => 'factory_girl'
  gem "baretest", "0.4.0.pre3"#, git: "git://github.com/apeiros/baretest.git"
  gem "ruby-debug19"
end
