require 'byebug'

class StaticAssets
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    if req.path.match(/^\/assets\//)
      this_dir = File.expand_path(File.dirname(__FILE__))
      full_path = this_dir + "/../../app" + req.path
      if File.exists?(full_path)
        ['200', {"Content-type" => get_content_type(req)}, [File.read(full_path)] ]
      else
        ['404', {}, ["File not found"]]
      end
    else
      app.call(env)
    end
  end

  def get_content_type(req)
    extension = Regexp.new(/(?<ext>.{4}$)/)
    match_data = extension.match(req.path)
    Rack::Mime::MIME_TYPES[match_data[:ext]]
  end
end
