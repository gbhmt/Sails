require_relative './model_base/sql_object_base'

class Model < SQLObjectBase
  def initialize(params = {})
    super(params)
  end

  def errors
    @errors ||= []
  end

  def valid?
  end

  finalize!
end
