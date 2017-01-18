require_relative 'model_base/sql_object_base.rb'
require_relative 'human'



class Cat < SQLObjectBase
  finalize!

  belongs_to :owner,
    foreign_key: :owner_id,
    primary_key: :id,
    class_name: 'Human'

  has_one_through :house, :owner, :house

  def initialize(params = {})
    super(params)
  end

  def errors
    @errors ||= []
  end

  def valid?
  end

end
