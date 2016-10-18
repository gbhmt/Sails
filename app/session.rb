require 'json'

class Session
  attr_accessor :content

  def initialize(req)
    @content = {}
    if req.cookies['_rails_lite_app']
      @content = JSON.parse(req.cookies['_rails_lite_app'])
    end
  end

  def [](key)
    @content[key]
  end

  def []=(key, val)
    @content[key] = val
  end

  def store_session(res)
    json_content = @content.to_json
    res.set_cookie('_rails_lite_app', {
      path: "/",
      value: json_content
    })
  end
end
