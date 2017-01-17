require_relative 'controller_base'
require_relative '../models/cat.rb'

class CatsController < ControllerBase

  def index
    @cats = Cat.all
  end

  def show
    @cat = Cat.find(params[:id])
    not_found if @cat.nil?
  end

end
