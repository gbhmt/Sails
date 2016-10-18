require 'rack'
require_relative 'lib/static_assets'
require_relative 'lib/show_exceptions'
require_relative 'routes'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  ROUTER.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use ShowExceptions
  use StaticAssets
  run app
end.to_app

Rack::Server.start(
  app: app,
  Port: 3000
)

run app
