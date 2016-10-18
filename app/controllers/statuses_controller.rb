class StatusesController < ControllerBase
  $statuses = [
    { id: 1, cat_id: 1, text: "Curie loves string!" },
    { id: 2, cat_id: 2, text: "Markov is mighty!" },
    { id: 3, cat_id: 1, text: "Curie is cool!" }
  ]

  def index
    statuses = $statuses.select do |s|
      s[:cat_id] == Integer(params['cat_id'])
    end

    render_content(statuses.to_json, "application/json")
  end
end
