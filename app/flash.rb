require 'json'

class Flash
  attr_accessor :old_content, :new_content
  def initialize(req)
    @new_content = {}
    @old_content = {}
    if req.cookies['_sails_flash']
      @old_content = JSON.parse(req.cookies['_sails_flash'])
    end
  end

  def [](key)
    @new_content[key.to_s]
    @old_content[key.to_s]
  end

  def []=(key, val)
    @new_content[key.to_s] = val
    @old_content[key.to_s] = val
  end

  def now
    @old_content
  end

  def store_flash(res)
    json_content = @new_content.to_json
    res.set_cookie('_sails_flash', {
      path: "/",
      value: json_content
    })
  end

end
