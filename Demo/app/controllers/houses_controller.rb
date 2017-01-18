require_relative 'controller_base'
require_relative '../models/house.rb'

class HousesController < ControllerBase

  def index
    @houses = House.all
  end

  def show
    @house = House.find(params[:id].to_i)
    not_found if @house.nil?
  end

end
