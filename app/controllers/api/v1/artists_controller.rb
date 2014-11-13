class Api::V1::ArtistsController < ApplicationController
	respond_to :html, :xml, :json
	skip_before_action :verify_authenticity_token

	def index
		@artists = Artist.all 
		respond_with @artists
	end

	def show
		@artist = Artist.find(params[:id])
		respond_with @artist
	end

	def create
		@artist = Artist.new
		@artist.name = params[:name]
		@artist.country = params[:country]
		@artist.description = params[:description]	
		@artist.dob = Date.parse(params[:dob]) unless params[:dob].nil?
		@artist.website = params[:website]
		@artist.save
		respond_with @artist
	end

	def update
		@artist = Artist.find(params[:id])
		@artist.name = params[:name] unless params[:name].nil?
		@artist.country = params[:country] unless params[:country].nil?
		@artist.description = params[:description] unless params[:description].nil?
		@artist.dob = Date.parse(params[:dob]) unless params[:dob].nil?
		@artist.website = params[:website] unless params[:website].nil?
		@artist.save
		respond_with @artist
	end

	def destroy
		@artist = Artist.find(params[:id])
		@artist.destroy
		respond_with @artist
	end
end
