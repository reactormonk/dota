require 'crudtree/interface/usher/rack'
require 'crudtree/helper'
Rango::Router.app = Usher::Interface.for(:rack) do
  extend CRUDtree::Interface::Usher::Rack
  extend CRUDtree::Interface::Helper
  resource(klass: Games, model: Game)
  resource(klass: Players, model: Player)
  resource(klass: Leagues, model: League)
  get("/").to(ShowCase.dispatcher(:index)).name(:showcase)
end
