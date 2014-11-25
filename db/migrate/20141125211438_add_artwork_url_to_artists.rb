class AddArtworkUrlToArtists < ActiveRecord::Migration
  def change
  	add_column :artists, :picture_url, :string
  end
end
