class Api::V1::SongsController < ApplicationController

	respond_to :html, :xml, :json
	skip_before_action :verify_authenticity_token


	resource_description do
		short 'Songs stored in the database'
		description 'Song object represents a record. From relationship
			  		perspective it BELOGNS TO album and no child objects. Fields for
			  		song object are name, length, and data (url to storage facility)'				
	end


	######################################################

	api :GET, '/songs', 'List all songs'

	def index
		@songs = Song.all
		respond_with @songs
	end

	######################################################

	api :GET, '/songs/:id', 'Get song with the specified identifier'
	param :id, String, :desc => "identifier of the song", :required => true

	def show
		@song = Song.find(params[:id])
		respond_with @song
	end

	######################################################

	api :POST, '/songs/', 'Create new song'
	param :name, String, :desc => "name of the song", :required => false
	param :length, String, :desc => "length of the song in seconds", :required => false

	def create
		@song = Song.new
		@song.name = params[:name]
		@song.length = params[:length]		
		@song.save 
		respond_with @song
	end

	######################################################

	api :PUT, '/songs/:id', 'Update existing song with the specified identifier'
	param :id, String, :desc => "identifier of the song", :required => true
	param :name, String, :desc => "name of the song", :required => false
	param :length, String, :desc => "length of the song in seconds", :required => false

	def update
		@song = Song.find(params[:id])
		@song.name = params[:name] unless params[:name].nil?
		@song.length = params[:length] unless params[:length].nil?
		@song.save
		respond_with @song
	end

	######################################################

	api :DELETE, '/songs/:id', 'Delete existing song with the specified identifier'
	param :id, String, :desc => "identifier of the song", :required => true

	def destroy
		@song = Song.find(params[:id])
		@song.destroy
		respond_with @song
	end
end
