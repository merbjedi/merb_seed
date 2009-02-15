require 'datamapper'

module DataMapper::Model
  # Creates a single record of seed data for use
  # with the db:seed rake task. 
  # 
  # === Parameters
  # constraints :: Immutable reference attributes. Defaults to :id
  def seed(*constraints, &block)
    MerbSeed::Seeder.plant(self, *constraints, &block)
  end

  def seed_many(*constraints)
    seeds = constraints.pop
    seeds.each do |seed_data|
      seed(*constraints) do |s|
        seed_data.each_pair do |k,v|
          s.send "#{k}=", v
        end
      end
    end
  end
  
  def column_names
    properties.map{|i| i.field }
  end
end