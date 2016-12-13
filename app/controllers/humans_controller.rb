require_relative 'controller_base'
require_relative '../models/human.rb'

class HumansController < ControllerBase

  def index
    @humans = Human.all
    render :index
  end


  # def create
  #   @human = Human.new(fname, lname, house_id)
  #   @human.save
  # end
end
