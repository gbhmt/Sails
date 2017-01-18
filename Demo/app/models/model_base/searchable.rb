require_relative '../../../config/db_connection'

module Searchable
  def where(params)
    where_line = params.map do |col, _|
      "#{col} = ?"
    end.join(" AND ")
    results = DBConnection.execute(<<-SQL, *params.values.map(&:to_s))
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL
    parse_all(results)
  end
end
