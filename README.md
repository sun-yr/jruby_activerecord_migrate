Install JRuby
================
Download Jruby (1.1.4 as I write this) and extract it somewhere. For me I've dumped it in "~/dev/jruby-1.1.4". Set an environment variable called JRUBY_HOME that points to this location; EX: in .bash_profile: export JRUBY_HOME="~/dev/jruby-1.1.4". Add JRUBY_HOME/bin to your path and you're good to go; EX: in .bash_profile: export PATH=$PATH:$JRUBY_HOME/bin

Install Required Gems
===================

	jruby -S gem install jruby-openssl (we won't use this, but JRuby will complain when installing gems without it)
	jruby -S gem install activerecord
	jruby -S gem install rake
	jruby -S gem install activerecord-jdbcmysql-adapter
Since we're using the jdbcmysql adapter we'll need to throw the mysql jdbc driver into our JRUBY_HOME/lib directory.


Configure the Project
=====================

	adapter: jdbcmysql
	host: localhost
	database: jruby_ar
	username: root
	password: 


Prepare Your Rakefile
=====================

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



Write Your Migration
=======================

The migration above is a Class that extends ActiveRecord Migration, it defines two instances methods named "up" and "down". The "up" method calls a method (on Migration) called create_table and passes it a block. When create_table executes the block it will pass it a "TableDefnition" instance, which we named "T". We then call the "string" method on the TableDefinition and pass it "symbols" stating the name and a map (the comma-delimited name/value pairs) containing the options for the column. The "down" method just calls the "drop_table" method. If I have to explain what that does, you're in way over your head :)
OK, let's try it! Bring open a terminal to your "db" folder and run "jruby -S rake migrate". The "-S" I keep using tells Jruby to execute one of command from JRUBY_HOME/bin. If all goes well you should see the following output:

	(in C:/source/activerecord)
	== 1 CreateUserTable: migrating ===============================================
	-- create_table(:user)
	-> 0.0031s
	-> 0 rows
	== 1 CreateUserTable: migrated (0.0036s) ======================================

Once we've executed this migration we should be able to see our new table in mysql:

	mysql> show tables;
	+-------------------+
	| Tables_in_test    |
	+-------------------+
	| schema_migrations |
	| user              |
	+-------------------+
The user table is our new table and the schema_migrations table was created by ActiveRecord to track the current version essentially. ActiveRecord actually keeps track of all the migrations applied to it as of ActiveRecord 2.0. If you see a schema_versions, table then you weren't following along very well as you have a really old version of ActiveRecord :)

References
==============
http://rails.aizatto.com/2007/05/27/activerecord-migrations-without-rails/
http://api.rubyonrails.org/classes/ActiveRecord/Migration.html
http://www.scribd.com/doc/1083725/Migrations-in-Rails-20