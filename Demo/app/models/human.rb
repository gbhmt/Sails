require_relative 'model_base/sql_object_base.rb'
require_relative 'house'
require_relative 'cat'



class Human < SQLObjectBase
  self.table_name = "humans"
  finalize!

  belongs_to :house
  has_many :cats,
    foreign_key: :owner_id,
    primary_key: :id,
    class_name: 'Cat'

  def initialize(params = {})
    super(params)
  end

  def full_name
    fname + ' ' + lname
  end

  def errors
    @errors ||= []
  end

  def valid?
  end

end
