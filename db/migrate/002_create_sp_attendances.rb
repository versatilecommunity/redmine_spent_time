class CreateSpAttendances < ActiveRecord::Migration
  
  def change
    create_table :sp_attendances do |t|
		t.references :user, :null => false, :index => true
		t.datetime :start_time
		t.datetime :end_time
		t.float :hours
		t.timestamps null: false
    end	
  end
end
