require "active_record"
require "yaml"
require "logger"

task :default => :usage

task :usage do
  print "Executing \"rake migrate\" will bring the databse up to date\n"
  print "To upgrade/downgrade to a specific version use: \"rake migrate VERSION=X\"\n"
end

task :migrate => :configure do
  ActiveRecord::Migrator.migrate("db/migration", ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
end

task :configure do
  ActiveRecord::Base.establish_connection(YAML::load(File.open("db/database.yml")))
  ActiveRecord::Base.logger = Logger.new(File.open('migrate.log', 'a'))
end
