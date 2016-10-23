require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative '../session'
require_relative '../flash'


class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @@protected ||= false
    @req, @res = req, res
    @params = req.params.merge(route_params)
  end

  def self.protect_from_forgery
    @@protected = true
  end

  def already_built_response?
    !!@already_built_response
  end

  def redirect_to(url)
    res["Location"] = url
    res.status = 302
    raise if already_built_response?
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  def render_content(content, content_type)
    res["Content-Type"] = content_type
    res.write(content)
    raise if already_built_response?
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  def render(template_name)
    subdirectory = self.class.to_s.underscore.split("_controller")[0]
    template_file = "views/#{subdirectory}/#{template_name}.html.erb"
    contents = File.read(template_file)
    template = ERB.new(contents).result(binding)
    render_content(template, "text/html")
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def form_authenticity_token
    @token = {}
    if req.cookies['authenticity_token']
      @token = req.cookies['authenticity_token']
    end
    @res.set_cookie('authenticity_token', {
      path: "/",
      value: @token
    })
    @token.to_json
  end

  def check_authenticity_token
    raise "Invalid authenticity token" unless @req.cookies['authenticity_token'].to_json == form_authenticity_token
  end

  def invoke_action(name)
    if ControllerBase.protect_from_forgery && @req.request_method != "GET"
      check_authenticity_token
    end
    self.send(name)
    render(name) unless already_built_response?
  end
end
