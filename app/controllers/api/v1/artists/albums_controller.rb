class Api::V1::Artists::AlbumsController < ApplicationController

	respond_to :html, :xml, :json
	skip_before_action :verify_authenticity_token

	resource_description do
		short 'Artist - album relationship'
		description 'The endpoints below allow you to establish and
					delete relationship between artists and albums'				
	end


	######################################################

	api :GET, '/artists/:artist_id/albums', 'List all albums of the artist with the specified identifier'
	param :artist_id, String, :desc => "identifier of the artist", :required => true

	def index
		artist = Artist.find(params[:artist_id])
		@albums = artist.albums
		respond_with @albums
	end

	######################################################

	api :GET, '/artists/:artist_id/albums/:id', 'Get album with the specified identifier, of the artist with the specified identifier'
	param :artist_id, String, :desc => "identifier of the artist", :required => true
	param :id, String, :desc => "identifier of the album", :required => true
	
	def show
		artist = Artist.find(params[:artist_id])
		@album = artist.albums.find(params[:id])
		respond_with @album
	end

	######################################################

	api :POST, '/artists/:artist_id/albums', 'Create new album or attach already exising one to the artist with the specified identifier'
	param :artist_id, String, :desc => "identifier of the artist", :required => true
	param :album_id, String, :desc => "identifier of the album (if attaching already exising one)", :required => false
	param :name, String, :desc => "name of the album", :required => false
	param :genre, String, :desc => "genre of the album", :required => false
	param :release_date, Date, :desc => "release date of the album", :required => false
	param :description, String, :desc => "additional description of the album", :required => false
	param :artwork_data, File, :desc => "cover picture of the album", :required => false

	def create
		artist = Artist.find(params[:artist_id])
		@album = nil
		if not params[:album_id].nil? then
			@album = Album.find(params[:album_id])
		else
			@album = Album.new
			@album.name = params[:name]
			@album.genre = params[:genre]
			@album.release_date = Date.parse(params[:release_date]) unless params[:release_date].nil?
			@album.description = params[:description]
			@album.save

			if not params[:artwork_data].nil? then
				s3 = AWS::S3.new
				response = s3.buckets["tunesheap-content"].objects["#{@album.id}-album-artwork" ].write(:file => params[:artwork_data].tempfile.path)
				@album.artwork_url = response.public_url.to_s
				@album.save
			end
		end

		artist.albums << @album
		artist.save
		respond_with @album
	end

	######################################################

	api :PUT, '/artists/:artist_id/albums/:id', 'Update exising album with the specified identifier of the artist with the specified identifier'
	param :artist_id, String, :desc => "identifier of the artist", :required => true
	param :id, String, :desc => "identifier of the album", :required => true
	param :name, String, :desc => "name of the album", :required => false
	param :genre, String, :desc => "genre of the album", :required => false
	param :release_date, Date, :desc => "release date of the album", :required => false
	param :description, String, :desc => "additional description of the album", :required => false
	param :artwork_data, File, :desc => "cover picture of the album", :required => false

	def update
		artist = Artist.find(params[:artist_id])
		@album = artist.albums.find(params[:id])
		@album.name = params[:name] unless params[:name].nil?
		@album.genre = params[:genre] unless params[:genre].nil?
		@album.release_date = Date.parse(params[:release_date]) unless params[:release_date].nil?
		@album.description = params[:description] unless params[:description].nil?

		if not params[:artwork_data].nil? then
			s3 = AWS::S3.new
			response = s3.buckets["tunesheap-content"].objects["#{@album.id}-album-artwork" ].write(:file => params[:artwork_data].tempfile.path)
			@album.artwork_url = response.public_url.to_s			
		end
		
		@album.save
		respond_with @album
	end

	######################################################

	api :DELETE, '/artists/:artist_id/albums/:id', 'Remove existing album with the specified identifier (removes relationship not the album object itself)'
	param :artist_id, String, :desc => "identifier of the artist", :required => true
	param :id, String, :desc => "identifier of the album", :required => true

	def destroy
		artist = Artist.find(params[:artist_id])
		@album = artist.albums.find(params[:id])
		artist.albums.delete(@album)
		respond_with @album
	end

end