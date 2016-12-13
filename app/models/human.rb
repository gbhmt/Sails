require_relative 'model_base/sql_object_base.rb'



class Human < SQLObjectBase
  self.table_name = "humans"
  finalize!

  has_many :houses

  def initialize(params = {})
    super(params)
  end

  def errors
    @errors ||= []
  end

  def valid?
  end

end
