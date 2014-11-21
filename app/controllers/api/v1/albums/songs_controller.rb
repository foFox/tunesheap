class Api::V1::Albums::SongsController < ApplicationController

	respond_to :html, :xml, :json
	skip_before_action :verify_authenticity_token

		resource_description do
		short 'Albom - songs relationship'
		description 'The endpoints below allow you to establish and
					delete relationship between albums and songs'				
	end


	######################################################

	api :GET, '/albums/:album_id/songs', 'List all songs from the album with the specified identifier'
	param :album_id, String, :desc => "identifier of the album", :required => true

	def index
		album = Album.find(params[:album_id])
		@songs = album.songs
		respond_with @songs
	end

	######################################################

	api :GET, '/albums/:album_id/songs/:id', 'Get song with the specified identifier, from the album with the specified identifier'
	param :album_id, String, :desc => "identifier of the album", :required => true
	param :id, String, :desc => "identifier of the song", :required => true

	def show
		album = Album.find(params[:album_id])
		@song = album.songs.find(params[:id])
		respond_with @song
	end

	######################################################

	api :POST, '/albums/:album_id/songs', 'Create new song or attach already exising one to the album with the specified identifier'
	param :album_id, String, :desc => "identifier of the album", :required => true
	param :song_id, String, :desc => "identifier of the song (if attaching already exising one)", :required => false
	param :name, String, :desc => "name of the song", :required => false
	param :length, String, :desc => "length of the song in seconds", :required => false

	def create
		album = Album.find(params[:album_id])
		@song = nil

		if not params[:song_id].nil? then
			@song = Song.find(params[:song_id])
		else 
			@song = Song.new
			@song.name = params[:name]
			@song.length = params[:length]		
			@song.save 
		end

		album.songs << @song
		album.save
		respond_with @song
	end

	######################################################

	api :PUT, '/albums/:album_id/songs/:id', 'Update exising song with the specified identifier from the album with the specified identifier'
	param :album_id, String, :desc => "identifier of the album", :required => true
	param :id, String, :desc => "identifier of the song", :required => true
	param :name, String, :desc => "name of the song", :required => false
	param :length, String, :desc => "length of the song in seconds", :required => false

	def update
		album = Album.find(params[:album_id])
		@song = album.songs.find(params[:id])
		@song.name = params[:name] unless params[:name].nil?
		@song.length = params[:length] unless params[:length].nil?
		@song.save
		respond_with @song
	end

	######################################################

	api :DELETE, '/albums/:album_id/songs/:id', 'Remove existing song with the specified identifier (removes relationship not the song object itself)'
	param :album_id, String, :desc => "identifier of the album", :required => true
	param :id, String, :desc => "identifier of the song", :required => true

	def destroy
		album = Album.find(params[:album_id])
		@song = album.songs.find(params[:id])
		album.songs.delete @song
		respond_with @song
	end

end