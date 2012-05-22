class CreateUserRole < ActiveRecord::Migration
	def self.up
		create_table :userrole do |t|
			t.integer :user_id
			t.integer :role_id

			t.timestamps
		end
	end

	def self.down
		drop_table :userrole
	end
end