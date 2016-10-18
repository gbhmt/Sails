require_relative 'lib/router'
this_dir = File.expand_path(File.dirname(__FILE__))
Dir["#{this_dir}/../app/controllers/*_controller.rb"].each { |file| require file }

ROUTER = Router.new

ROUTER.draw do
  get Regexp.new("^/cats$"), Cats2Controller, :index
  get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
end
