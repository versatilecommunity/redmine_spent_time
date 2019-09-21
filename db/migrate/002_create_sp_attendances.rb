class CreateSpAttendances < ActiveRecord::Migration[4.2]
  
  def change
    create_table :sp_attendances do |t|
		t.references :user, :null => false, :index => true
		t.datetime :start_time
		t.datetime :end_time
		t.float :hours
		t.references :branch, :class => "sp_branches", :null => true, :index => true
		t.timestamps null: false
    end	
  end
end
