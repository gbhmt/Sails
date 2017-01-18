require 'json'

class Session
  attr_accessor :content

  def initialize(req)
    @content = {}
    if req.cookies['_sails']
      @content = JSON.parse(req.cookies['_sails'])
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
    res.set_cookie('_sails', {
      path: "/",
      value: json_content
    })
  end
end
