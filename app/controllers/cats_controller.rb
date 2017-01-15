require_relative 'controller_base'
require_relative '../models/cat.rb'

class CatsController < ControllerBase

  def show
    @cat = Cat.find(params[:id].to_i)
    render :show
  end

end
