# Sails

### Overview

Sails is a lightweight, minimalistic MVC framework built in Ruby.

### Features

#### Router

The router's draw method takes four arguments: an http method, a route pattern, a controller class, and an action name. 

```ruby 

get Regexp.new("^/users/(?<user_id>\\d+)/statuses$"), StatusesController, :index

```

This will be parsed by the router and added to the router's cache of available routes. When a route is entered into the address bar in the browser, the router will check its saved routes and invoke the route's action in the route's corresponding controller.

#### ControllerBase

The controller is initialized on every request and calls the action given by the router. Its main instance methods are `render(template)`, which will render the given ERB template that lives in the `views` directory, and `redirect_to(url)`, which will store the url in the response headers and respond with a 302 status. I've also implemented session cookies and flashes, which will be sent along in the responses. 

#### Middlewares

I have also included two Rack middlewares that filter incoming requests: `ShowExceptions` and `StaticAssets`. `ShowExceptions` rescues bad requests that would normally result in a non-descriptive 500 Internal Server Error and renders the error and stack trace in an `exceptions.html.erb` template. `StaticAssets` parses request URLs that look in the `assets` folder and sets the content-type headers to the appropriate mime type and serves the requested assets in the response.

### Upcoming Improvements
 * Custom built ORM for models
