# encoding: utf-8

# database connection
case
when Rango.development?
  DataMapper.setup(:default, "sqlite3:db/#{Rango.environment}.db")
when Rango.testing?
  DataMapper.setup(:default, "sqlite3::memory:")
end

