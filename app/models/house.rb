require_relative 'model_base/sql_object_base.rb'


class House < SQLObjectBase
  finalize!

  has_many :humans

  def initialize(params = {})
    super(params)
  end

  def errors
    @errors ||= []
  end

  def valid?
  end

end
