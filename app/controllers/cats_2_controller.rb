require_relative 'controller_base'

class Cats2Controller < ControllerBase
  $cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
  ]
  def index
    render_content($cats.to_json, "application/json")
  end
end
