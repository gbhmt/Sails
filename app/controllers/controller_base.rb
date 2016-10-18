require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative '../session'
require_relative '../flash'


class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @@protected ||= false
    @req, @res = req, res
    @params = @req.params.merge(route_params)
  end

  def self.protect_from_forgery
    @@protected = true
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    @res["Location"] = url
    @res.status = 302
    raise if already_built_response?
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    @res["Content-Type"] = content_type
    @res.write(content)
    raise if already_built_response?
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template_file = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    contents = File.read(template_file)
    template = ERB.new(contents).result(binding)
    render_content(template, "text/html")
  end

  # method exposing a `Session` object
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


  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    if ControllerBase.protect_from_forgery && @req.request_method != "GET"
      check_authenticity_token
    end
    self.send(name)
    render(name) unless already_built_response?
  end
end