require 'crudtree/interface/usher/rack'
require 'crudtree/helper'
Rango::Router.app = Usher::Interface.for(:rack) do
  extend CRUDtree::Interface::Usher::Rack
  extend CRUDtree::Interface::Helper
  resource(klass: Games, model: Game) do
    collection(call: :staged)
    collection(call: :running)
  end
  resource(klass: Players, model: Player, identifier: :login)
  resource(klass: Leagues, model: League)
  get("/").to(ShowCase.dispatcher(:index)).name(:showcase)
  get("/login").to(Players.dispatcher(:login)).name(:login)
  post("/login").to(Players.dispatcher(:login!))
end
