require 'json'

class Flash
  attr_accessor :old_content, :new_content
  def initialize(req)
    @new_content = {}
    if req.cookies['_rails_lite_app']
      @old_content = JSON.parse(req.cookies['_rails_lite_app'])
    end
  end

  def [](key)
    @new_content[key]
    @old_content[key]
  end

  def []=(key, val)
    @new_content[key] = val
    @old_content[key] = val
  end

  def now
    @old_content
  end

  def store_flash(res)
    json_content = @new_content.to_json
    res.set_cookie('_rails_lite_app', {
      path: "/",
      value: json_content
    })
  end

end
