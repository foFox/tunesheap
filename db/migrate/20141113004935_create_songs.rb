class CreateSongs < ActiveRecord::Migration
 	def change
    	create_table :songs do |t|
    		t.string :name
    		t.integer :length
    		t.string :data
    		t.integer :album_id
     		t.timestamps
    	end
  	end
end
