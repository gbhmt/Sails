require_relative 'lib/router'
this_dir = File.expand_path(File.dirname(__FILE__))
Dir["#{this_dir}/../app/controllers/*_controller.rb"].each { |file| require_relative file }

ROUTER = Router.new

ROUTER.draw do
  get Regexp.new("^/humans$"), HumansController, :index

end
