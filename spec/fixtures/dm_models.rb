require 'dm-core'

# setup repository
DataMapper.setup(:default, "sqlite3::memory:")

# setup models
class User
  include DataMapper::Resource

  property :id,         Serial
  property :login,      String
  property :first_name, String
  property :last_name,  String
  property :title,      String
end

User.auto_migrate!
