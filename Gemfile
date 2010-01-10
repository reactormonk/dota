# encoding: utf-8

# === Usage === #
# Run gem bundle for installation. You have to have bundler gem installed.

# http://github.com/wycats/bundler
# http://litanyagainstfear.com/blog/2009/10/14/gem-bundler-is-the-future
# http://yehudakatz.com/2009/11/03/using-the-new-gem-bundler-today
# http://www.engineyard.com/blog/2009/using-the-rubygems-bundler-for-your-app

# === Shared Gems === #
# Specify a dependency on rango. When the bundler downloads gems,
# it will download rango as well as all of rango' dependencies
gem "rango"#, git: "git://github.com/botanicus/rango.git"
gem "rack"#, git: "git://github.com/rack/rack.git"
gem "rubyexts"
gem "media-path"

# router
gem "usher"#, git: "git://github.com/joshbuddy/usher.git"
gem "fancyroutes", git: "git://github.com/tred/fancyroutes.git"

# template engine
gem "haml"#, git: "git://github.com/nex3/haml.git"
gem "tilt"

# ORM
gem "dm-core"#, git: "git://github.com/datamapper/dm-core.git"
gem "dm-timestamps"#, git: "git://github.com/datamapper/dm-more.git"
gem "dm-types"#, git: "git://github.com/datamapper/dm-more.git"
gem "dm-validations"#, git: "git://github.com/datamapper/dm-more.git"
gem "dm-aggregates"#, git: "git://github.com/datamapper/dm-more.git" # for count etc

gem "state_machine", git: "git://github.com/pluginaweek/state_machine.git"
gem "bcrypt-ruby"

gem "thin", require_as: nil#, git: "git://github.com/macournoyer/thin.git" # there seems to be some problems with latest thin
#gem "unicorn", require_as: nil#, git: "git://repo.or.cz/unicorn.git"
gem "racksh", require_as: nil#, git: "git://github.com/sickill/racksh.git"

# === Environment-Specific Setup === #
only(:development) do
  gem "shotgun", require_as: nil#, git: "git://github.com/rtomayko/shotgun.git"
end

except(:stage, :production) do
  gem "do_sqlite3"#, git: "git://github.com/datamapper/do.git"
end

bundle_path "gems"
bin_path "bin"
