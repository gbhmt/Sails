require_relative 'model_base/sql_object_base.rb'
require_relative 'human'



class Cat < SQLObjectBase
  finalize!

  belongs_to :human,
    foreign_key: :owner_id,
    primary_key: :id,
    class_name: 'Human'

  has_one :house, :human, :house

  def initialize(params = {})
    super(params)
  end

  def errors
    @errors ||= []
  end

  def valid?
  end

end
