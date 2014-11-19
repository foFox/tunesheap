class Api::V1::SongsController < ApplicationController

	respond_to :html, :xml, :json
	skip_before_action :verify_authenticity_token

	def index
		@songs = Song.all
		respond_with @songs
	end

	def show
		@song = Song.find(params[:id])
		respond_with @song
	end

	def create
		@song = Song.new
		@song.name = params[:name]
		@song.length = params[:length]		
		@song.save 
		respond_with @song
	end

	def update
		@song = Song.find(params[:id])
		@song.name = params[:name] unless params[:name].nil?
		@song.length = params[:length] unless params[:length].nil?
		@song.save
		respond_with @song
	end

	def destroy
		@song = Song.find(params[:id])
		@song.destroy
		respond_with @song
	end
end
