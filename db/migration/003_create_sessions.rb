class CreateSessions < ActiveRecord::Migration
	def self.up
		create_table :sessions do |t|
			t.string :hash
			t.string :user_id
			t.string :ip_addr
			t.datetime :expires_at

			t.timestamps
		end
	end

	def self.down
		drop_table :sessions
	end
end
