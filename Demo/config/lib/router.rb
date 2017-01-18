class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name =
      pattern, http_method, controller_class, action_name
  end

  def matches?(req)
    (pattern =~ req.path) && (http_method == req.request_method.downcase.to_sym)
  end

  def run(req, res)
    match_data = pattern.match(req.path)
    route_params = {}
    if match_data
      match_data.names.each do |name|
        route_params[name.to_sym] = match_data[name]
      end
    end
    controller_class.new(req, res, route_params).invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def not_found
    Route.new('/not_found', "get", ControllerBase, "not_found")
  end

  def add_route(pattern, method, controller_class, action_name)
    routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete, :patch].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    routes.each do |route|
      return route if route.matches?(req)
    end
    nil
  end

  def run(req, res)
    matched_route = match(req)
    if matched_route
      matched_route.run(req, res)
    else
      not_found.run(req, res)
    end
  end
end
