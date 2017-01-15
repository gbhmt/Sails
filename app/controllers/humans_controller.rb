require_relative 'controller_base'
require_relative '../models/human.rb'
require 'byebug'

class HumansController < ControllerBase

  def index
    @humans = Human.all
    render :index
  end

  def show
    @human = Human.find(params[:id].to_i)
    if @human.nil?
      render :not_found
    else
      render :show
    end
  end

end
