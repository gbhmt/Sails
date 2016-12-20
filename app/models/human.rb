require_relative 'model_base/sql_object_base.rb'
require_relative 'house'



class Human < SQLObjectBase
  self.table_name = "humans"
  finalize!

  belongs_to :house

  def initialize(params = {})
    super(params)
  end

  def errors
    @errors ||= []
  end

  def valid?
  end

end
