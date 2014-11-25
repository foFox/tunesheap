class Api::V1::ArtistsController < ApplicationController

	respond_to :html, :xml, :json
	skip_before_action :verify_authenticity_token

	resource_description do
		short 'Artists stored in the database'
		description 'Artist object represents a single singer or band. From relationship
			  		perspective it has not parent object and HAS MANY albums. Fields for
			  		artist object are name, country, description, and date of birth'				
	end


	######################################################

	api :GET, '/artists', 'List all artists'

	def index
		@artists = Artist.all 
		respond_with @artists
	end

	######################################################

	api :GET, '/artists/:id', 'Get artist with the specified identifier'
	param :id, String, :desc => "identifier of the artist", :required => true

	def show
		@artist = Artist.find(params[:id])
		respond_with @artist
	end

	######################################################

	api :POST, '/artists/', 'Create new artist'
	param :name, String, :desc => "name of the artist", :required => false
	param :country, String, :desc => "place of birth of the artist", :required => false
	param :description, String, :desc => "additional description of the artist", :required => false
	param :dob, String, :desc => "date of birth of the artist", :required => false
	param :website, String, :desc => "url of the aritst's website", :required => false
	param :picture_data, File, :desc => "picture of the artist", :required => false 

	def create
		@artist = Artist.new
		@artist.name = params[:name]
		@artist.country = params[:country]
		@artist.description = params[:description]	
		@artist.dob = Date.parse(params[:dob]) unless params[:dob].nil?
		@artist.website = params[:website]
		@artist.save

		if not params[:picture_data].nil? then
			s3 = AWS::S3.new
			response = s3.buckets["tunesheap-content"].objects["#{@artist.id}-artist-picture" ].write(:file => params[:picture_data].tempfile.path)
			@artist.picture_url = response.public_url.to_s
			@artist.save
		end

		respond_with @artist
	end

	######################################################

	api :PUT, '/artists/:id', 'Update existing artist with the specified identifier'
	param :id, String, :desc => "identifier of the artist", :required => true
	param :name, String, :desc => "name of the artist", :required => false
	param :country, String, :desc => "place of birth of the artist", :required => false
	param :description, String, :desc => "additional description of the artist", :required => false
	param :dob, String, :desc => "date of birth of the artist", :required => false
	param :website, String, :desc => "url of the aritst's website", :required => false
	param :picture_data, File, :desc => "picture of the artist", :required => false

	def update
		@artist = Artist.find(params[:id])
		@artist.name = params[:name] unless params[:name].nil?
		@artist.country = params[:country] unless params[:country].nil?
		@artist.description = params[:description] unless params[:description].nil?
		@artist.dob = Date.parse(params[:dob]) unless params[:dob].nil?
		@artist.website = params[:website] unless params[:website].nil?

		if not params[:picture_data].nil? then
			s3 = AWS::S3.new
			response = s3.buckets["tunesheap-content"].objects["#{@artist.id}-artist-picture" ].write(:file => params[:picture_data].tempfile.path)
			@artist.picture_url = response.public_url.to_s
		end

		@artist.save
		respond_with @artist
	end

	######################################################

	api :DELETE, '/artists/:id', 'Delete existing artist with the specified identifier'
	param :id, String, :desc => "identifier of the artist", :required => true

	def destroy
		@artist = Artist.find(params[:id])
		@artist.destroy
		respond_with @artist
	end

end
