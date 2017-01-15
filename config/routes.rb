require_relative 'lib/router'
this_dir = File.expand_path(File.dirname(__FILE__))
Dir["#{this_dir}/../app/controllers/*_controller.rb"].each { |file| require_relative file }

ROUTER = Router.new

ROUTER.draw do
  get Regexp.new("^/humans$"), HumansController, :index
  get Regexp.new("^/humans/(?<id>\\d+)$"), HumansController, :show
  get Regexp.new("^/houses$"), HousesController, :index
  get Regexp.new("^/houses/(?<id>\\d+)$"), HousesController, :show
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show

end
