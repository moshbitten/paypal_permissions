class PppModelsController < ApplicationController
  def new
    @ppp = Ppp.new(:client_name => "The Moshbit")
  end
end
