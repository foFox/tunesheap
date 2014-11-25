class AddArtworkUrlToAlbums < ActiveRecord::Migration
  def change
  	add_column :albums, :artwork_url, :string
  end
end
