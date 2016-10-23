require_relative '../../config/db_connection'
require 'active_support/inflector'
require_relative 'searchable'
require_relative 'associatable'


class SQLObjectBase
  extend Associatable
  extend Searchable

  def self.columns
    unless @columns
     @columns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
     SQL
     .first.map { |column| column.to_sym }
     end
    @columns
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}") do
        attributes[column]
      end
      define_method("#{column}=") do |arg|
        attributes[column] = arg
      end
    end
  end

  def self.table_name=(table_name = nil)
    @table_name = table_name
  end

  def self.table_name
    if @table_name
      @table_name
    else
      self.to_s.tableize
    end
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |attrs|
      self.new(attrs)
    end
  end

  def self.find(id)
    attrs = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = #{id}
    SQL
    return nil if attrs.empty?
    self.new(attrs.first)
  end

  def initialize(params = {})
    params.each do |col, val|
      col = col.to_sym
      raise "unknown attribute '#{col}'" unless self.class.columns.include?(col)
      col = col.to_s + "="
      send(col, val)
    end
  end

  def attributes
    unless @attributes
      @attributes = {}
    end
    @attributes
  end

  def attribute_values
    self.class.columns.map do |column|
      self.send("#{column}")
    end
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * attribute_values.length).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map do |column|
      "#{column} = ?"
    end.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
      SQL
  end

  def save
    id.nil? ? insert : update
  end
end
