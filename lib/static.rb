class Static
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    if req.path.match(/^\/public\//)
      if File.exists?("./#{req.path}")
        ['200', {"Content-type" => get_content_type(req)}, [File.read("./#{req.path}")] ]
      else
        ['404', {}, ["File not found"]]
      end
    else
      app.call(env)
    end
  end

  def get_content_type(req)
    extension = Regexp.new(/(?<ext>.{3}$)/)
    match_data = extension.match(req.path)
    case match_data[:ext]
    when "jpg"
      "image/jpeg"
    when "png"
      "image/png"
    when "txt"
      "text/plain"
    when "zip"
      "application/zip"
    end
  end
end
