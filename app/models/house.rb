require_relative 'model_base/sql_object_base.rb'
require_relative 'human'


class House < SQLObjectBase
  finalize!

  has_many :humans,
    foreign_key: :house_id,
    primary_key: :id,
    class_name: 'Human'

  has_many_through :cats, :humans, :cats

  def initialize(params = {})
    super(params)
  end

  def errors
    @errors ||= []
  end

  def valid?
  end

end
