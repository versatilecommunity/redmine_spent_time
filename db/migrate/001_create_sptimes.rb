class CreateSptimes < ActiveRecord::Migration
  def change
	create_table :sp_addresses do |t|
	  t.string :address1
      t.string :address2
	  t.string :work_phone
      t.string :home_phone
	  t.string :mobile
      t.string :email
	  t.string :fax
      t.string :city
	  t.string :country
      t.string :state
      t.integer :pin
	  t.timestamps null: false
    end
  
    create_table :sp_companies do |t|
	  t.string :name, :null => false
      t.string :service_tax_number
      t.string :pan_number
      t.string :tin_cin_number
      t.string :tax_number
      t.date :established_year
	  t.string :website
	  t.references :address, :class => "sp_addresses", :null => true, :index => true
	  t.timestamps null: false
    end
	
	create_table :sp_branches do |t|
		t.string :name, :null => false
		t.date :established_year
		t.references :company, :class => "sp_companies", :null => true, :index => true
		t.references :address, :class => "sp_addresses", :null => true, :index => true
		t.timestamps null: false		
	end
	
	create_table :sp_permissions do |t|
		t.string :name
		t.string :short_name
		t.timestamps null: false
	end
	
	reversible do |dir|
		dir.up do				
			add_reference :users, :branch, :class => "sp_branches", :index => true
			add_reference :users, :permission, :class => "sp_permissions", :index => true
			
			execute <<-SQL
				INSERT INTO sp_permissions(id, name, short_name, created_at, updated_at) VALUES (1, 'OWNER', 'O', current_timestamp, current_timestamp);
			SQL
			
			execute <<-SQL
				INSERT INTO sp_permissions(id, name, short_name, created_at, updated_at) VALUES (2, 'MANAGER', 'M', current_timestamp, current_timestamp);
			SQL
			
			execute <<-SQL
				INSERT INTO sp_permissions(id, name, short_name, created_at, updated_at) VALUES (3, 'DEVELOPER', 'D', current_timestamp, current_timestamp);
			SQL
			
			execute <<-SQL
				INSERT INTO sp_permissions(id, name, short_name, created_at, updated_at) VALUES (4, 'REPORTER', 'R', current_timestamp, current_timestamp);
			SQL
			
			execute <<-SQL
				INSERT INTO sp_permissions(id, name, short_name, created_at, updated_at) VALUES (5, 'GUEST', 'G', current_timestamp, current_timestamp);
			SQL
		end

		dir.down do
			remove_reference :users, :branch
			remove_reference :users, :permission
		end 
	end
  end
end