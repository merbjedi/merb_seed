namespace :db do
  desc "Loads seed data from schema/data for the current environment."
  task :seed => :merb_env do
    require File.join( File.dirname(__FILE__), "seeder")
    
    # load ruby seed files
    seed_path = ENV["SEED_PATH"] ? ENV["SEED_PATH"] : (Merb::Plugins.config[:merb_seed][:seed_path] || "schema/data")
    Dir[File.join(Merb.root, seed_path, '*.rb')].sort.each { |seed| 
      puts "\n== Seeding from #{File.split(seed).last} " + ("=" * (60 - (17 + File.split(seed).last.length)))
      load seed 
      puts "=" * 60 + "\n"
    }
    
    # load environment specific seed files
    Dir[File.join(Merb.root, seed_path, Merb.env, '*.rb')].sort.each { |seed| 
      puts "\n== [#{Merb.env}] Seeding from #{File.split(seed).last} " + ("=" * (60 - (20 + File.split(seed).last.length + Merb.env.length)))
      load seed 
      puts "=" * 60 + "\n"
    }
    
    # load seed files from yml
    # TODO
  end
end