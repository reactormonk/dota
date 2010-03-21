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
gem "rango", git: "git://github.com/Tass/rango.git"
gem "rack"#, git: "git://github.com/rack/rack.git"
gem "rubyexts"
gem "media-path"
gem "rack-flash"
gem "helpers", git: "git://github.com/Tass/helpers.git"
gem "rack-r18n", git: "git://github.com/Tass/rack-r18n.git"

# router
gem "usher"#, git: "git://github.com/joshbuddy/usher.git"
gem "crudtree"#, git: "git://github.com/Tass/CRUDtree.git"

# template engine
gem "haml"#, git: "git://github.com/nex3/haml.git"
gem "tilt"
gem "styler", git: "git://github.com/Tass/styler.git"

# ORM
gem "data_objects"
gem "extlib"
gem "dm-core", git: "git://github.com/datamapper/dm-core.git"
gem "dm-timestamps", git: "git://github.com/Tass/dm-more.git"
gem "dm-types", git: "git://github.com/Tass/dm-more.git"
gem "dm-validations", git: "git://github.com/Tass/dm-more.git"
gem "dm-aggregates", git: "git://github.com/Tass/dm-more.git"

gem "state_machine", git: "git://github.com/pluginaweek/state_machine.git"

# auth
gem "bcrypt-ruby"
gem "warden"

gem "simple-logger"

# i18n
gem "r18n-core"

# === Environment-Specific Setup === #
group(:production) do
  gem "do_postgres"
end
