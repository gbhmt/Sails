require 'active_support/inflector'
require_relative '../../../config/db_connection'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      primary_key: :id,
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.camelcase
    }
    self.foreign_key = options[:foreign_key] || defaults[:foreign_key]
    self.primary_key = options[:primary_key] || defaults[:primary_key]
    self.class_name = options[:class_name] || defaults[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      primary_key: :id,
      foreign_key: "#{self_class_name.downcase}_id".to_sym,
      class_name: name.to_s.singularize.camelcase
    }
    self.foreign_key = options[:foreign_key] || defaults[:foreign_key]
    self.primary_key = options[:primary_key] || defaults[:primary_key]
    self.class_name = options[:class_name] || defaults[:class_name]
  end
end

module Associatable

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name.to_sym) do
      foreign_key = self.send(options.foreign_key)
      options.model_class.where(id: foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name.to_sym) do
      options.model_class.where("#{options.foreign_key}" => id)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name.to_sym) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      through_table = through_options.table_name
      source_table = source_options.table_name
      through_primary_key = through_options.primary_key
      source_primary_key = source_options.primary_key
      through_foreign_key = through_options.foreign_key
      source_foreign_key = source_options.foreign_key

      results = DBConnection.execute(<<-SQL, self.send(through_foreign_key))
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table} ON #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
        WHERE
          #{through_table}.#{through_primary_key} = ?
      SQL
      source_options.model_class.parse_all(results).first
    end
  end

  def assoc_options
    unless @assoc_options
      @assoc_options = {}
    end
    @assoc_options
  end
end
