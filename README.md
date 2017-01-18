# Sails

### Overview

Sails is a lightweight, minimalistic MVC framework built in Ruby.

### Features

#### Router

The router's draw method takes four arguments: an http method, a route pattern, a controller class, and an action name. 

`routes.rb`:
```ruby 

ROUTER.draw do
  get Regexp.new("^/humans/?$"), HumansController, :index
  get Regexp.new("^/humans/(?<id>\\d+)$"), HumansController, :show
  get Regexp.new("^/houses/?$"), HousesController, :index
  get Regexp.new("^/houses/(?<id>\\d+)$"), HousesController, :show
  get Regexp.new("^/cats/?$"), CatsController, :index
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
end

```

This will be parsed by the router and added to the router's cache of available routes. When a route is entered into the address bar in the browser, the router will check its saved routes and invoke the route's action in the route's corresponding controller. There is a built in not found route that will be run if the URL pattern does not match any of the routes defined.

`router.rb`:

```ruby

def not_found
    Route.new('/not_found', "get", ControllerBase, "not_found")
end
...
...
def run(req, res)
  matched_route = match(req)
  if matched_route
    matched_route.run(req, res)
  else
    not_found.run(req, res)
  end
end

```


#### ControllerBase

The controller is initialized on every request and calls the action given by the router. Its main instance methods are `render(template)`, which will render the given ERB template that lives in the `views` directory, and `redirect_to(url)`, which will store the URL in the response headers and respond with a 302 status. I've also implemented session cookies and flashes, which will be sent along in the responses. If the not found route is run, a static HTML template (`404.html`) will be rendered with a 404 status.

#### Middlewares

I have also included two Rack middlewares that filter incoming requests: `ShowExceptions` and `StaticAssets`. `ShowExceptions` rescues bad requests that would normally result in a non-descriptive 500 Internal Server Error and renders the error and stack trace in an `exceptions.html.erb` template. `StaticAssets` parses request URLs that look in the `assets` folder and sets the content-type headers to the appropriate mime type and serves the requested assets in the response.


#### ORM

Sails includes a basic object relational mapping for interacting with database objects. Models inherit from `SQLObjectBase`, which allows you to define instance and class methods, as well as an interface for finding, creating, and updating models, using metaprogramming to dynamically define getter and setter methods for the model's database columns. It also includes the module, `Searchable` that allows you to find all instances of a model satisfying the parameters passed in via a SQL where clause, and the module `Associatable`, an interface for creating associations between models, both at the direct level (i.e. belongs_to and has_many) and through direct level associations (i.e. has_one_through and has_many_through). 

`sql_object_base.rb`:

```ruby

def self.finalize!
  columns.each do |column|
    define_method("#{column}") do
      attributes[column]
    end
    define_method("#{column}=") do |arg|
      attributes[column] = arg
    end
  end
end
...
...
def insert
  col_names = self.class.columns.join(", ")
  question_marks = (["?"] * attribute_values.length).join(", ")
  DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
  SQL
  self.id = DBConnection.last_insert_row_id
end

def update
  set_line = self.class.columns.map do |column|
    "#{column} = ?"
  end.join(", ")
  DBConnection.execute(<<-SQL, *attribute_values, id)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = ?
    SQL
end
...
...
```

`searchable.rb`:

```ruby

def where(params)
  where_line = params.map do |col, _|
    "#{col} = ?"
  end.join(" AND ")
  results = DBConnection.execute(<<-SQL, *params.values.map(&:to_s))
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{where_line}
  SQL
  parse_all(results)
end

```

`associatable.rb`:

```ruby 

def has_many_through(name, through_name, source_name)
  define_method(name.to_sym) do
    through_options = self.class.assoc_options[through_name]
    source_options = through_options.model_class.assoc_options[source_name]
    through_table = through_options.table_name
    source_table = source_options.table_name
    through_primary_key = through_options.primary_key
    source_primary_key = source_options.primary_key
    through_foreign_key = through_options.foreign_key
    source_foreign_key = source_options.foreign_key
    results = DBConnection.execute(<<-SQL, self.send(through_primary_key))
      SELECT
        #{source_table}.*
      FROM
        #{through_table}
      JOIN
        #{source_table} ON #{through_table}.#{through_primary_key} = #{source_table}.#{source_foreign_key}
      WHERE
        #{through_table}.#{through_foreign_key} = ?
    SQL
    source_options.model_class.parse_all(results)
  end
end

```

### Demo

Included is a rudimentary demo of Sails' functionality. It features three models, `Human`, `House`, and `Cat`. These three models demonstrate Sails' ORM functionality through following associations: Humans belong to a house and have many cats, Houses have many residents and have many cats through its residents, and Cats belong to an owner and have one house through its owner. The association definition methods can define the necessary queries by setting fields via defaults based on a single argument (i.e. Humans belong to a house, and since the houses' model name is in fact House, Sails will build the rest) or in the case of associations that do not adhere to the associated model's name, the association definition can take arguments for foreign key, primary key, and class name (i.e. Houses have many residents, not many humans, so the definition must be more explicit). Through associations take arguments of association name, through association name, and source association name.

`house.rb`:

```ruby

class House < SQLObjectBase
  finalize!

  has_many :residents,
    foreign_key: :house_id,
    primary_key: :id,
    class_name: 'Human'

  has_many_through :cats, :residents, :cats
...
...

```

`human.rb`:

```ruby

class Human < SQLObjectBase
  self.table_name = "humans"
  finalize!

  belongs_to :house
  has_many :cats,
    foreign_key: :owner_id,
    primary_key: :id,
    class_name: 'Cat'
...
...

```

`cat.rb`:

```ruby

class Cat < SQLObjectBase
  finalize!

  belongs_to :owner,
    foreign_key: :owner_id,
    primary_key: :id,
    class_name: 'Human'

  has_one_through :house, :owner, :house
...
...

```

The routes listed in the Router section of this README are the corresponding routes for the demo. Any invalid URL will run the not found route, and each show action in the controller will run the ControllerBase's not_found method, rendering the same 404 template. The templates live in `app/views`, with each model's views in the appropriate sub-folder.

### Running the Demo

To run the demo, download `demo.zip` and follow these steps the command line:

* Navigate into the root directory of the demo
* Run `bundle install` to install dependencies
* Run `rackup config/server.ru` to start the server
* Navigate to any of the following index pages:
  * localhost:3000/humans
  * localhost:3000/houses
  * localhost:3000/cats
 
 #### Dependencies
 
 [Ruby](https://www.ruby-lang.org/en/)





### Future Improvements
 * Application layout that yields to other templates
 * Template partials
