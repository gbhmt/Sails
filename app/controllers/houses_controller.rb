require_relative 'controller_base'
require_relative '../models/house.rb'

class HousesController < ControllerBase

  def index
    @houses = House.all
    render :index
  end

  def show
    @house = House.find(params[:id].to_i)
    render :show
  end
  
end
