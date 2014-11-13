class CreateAlbums < ActiveRecord::Migration
	def change
    	create_table :albums do |t|
    		t.string :name
    		t.string :genre
    		t.datetime :release_date
    		t.string :description
    		t.integer :artist_id    		
    	  	t.timestamps
    	end
  	end
end
