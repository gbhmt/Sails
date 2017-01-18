require_relative 'controller_base'
require_relative '../models/human.rb'

class HumansController < ControllerBase

  def index
    @humans = Human.all
  end

  def show
    @human = Human.find(params[:id].to_i)
    not_found if @human.nil?
  end

end
