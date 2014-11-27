class Api::V1::AlbumsController < ApplicationController

	respond_to :html, :xml, :json
	skip_before_action :verify_authenticity_token

	resource_description do
		short 'Albums stored in the database'
		description 'Album object represents a single album created by 
			  		an artist, and it contains few songs. From relationship
			  		perspective it BELONGS TO artist and HAS MANY songs. 
			  		Fields for album object are name, genre, release date, 
			  		and description'				
	end

	######################################################

	api :GET, '/albums', 'List all albums'

	def index
		@albums = Album.all
		respond_with @albums
	end

	######################################################

	api :GET, '/albums/:id', 'Get album with the specified identifier'
	param :id, String, :desc => "identifier of the album", :required => true
	
	def show
		@album = Album.find(params[:id])
		respond_with @album
	end

	######################################################

	api :POST, '/albums/', 'Create new album'
	param :name, String, :desc => "name of the album", :required => false
	param :genre, String, :desc => "genre of the album", :required => false
	param :release_date, Date, :desc => "release date of the album", :required => false
	param :description, String, :desc => "additional description of the album", :required => false
	param :artwork_data, File, :desc => "cover picture of the album", :required => false

	def create
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

		respond_with @album
	end

	######################################################
	
	api :PUT, '/albums/:id', 'Update existing album with the specified identifier'
	param :id, String, :desc => "identifier of the album", :required => true
	param :name, String, :desc => "name of the album", :required => false
	param :genre, String, :desc => "genre of the album", :required => false
	param :release_date, Date, :desc => "release date of the album", :required => false
	param :description, String, :desc => "additional description of the album", :required => false
	param :artwork_data, File, :desc => "cover picture of the album", :required => false

	def update
		@album = Album.find(params[:id])
		@album.name = params[:name] unless params[:name].nil?
		@album.genre = params[:genre] unless params[:genre].nil?
		@album.release_date =Date.parse(params[:release_date]) unless params[:release_date].nil?
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

	api :DELETE, '/albums/:id', 'Delete existing album with the pecified identifier'
	param :id, String, :desc => "identifier of the album", :required => true
	
	def destroy
		@album = Album.find(params[:id])
		@album.destroy
		respond_with @album
	end
end
