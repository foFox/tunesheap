class Api::V1::AlbumsController < ApplicationController

	respond_to :html, :xml, :json
	skip_before_action :verify_authenticity_token

	def index
		@albums = Album.all
		respond_with @albums
	end

	def show
		@album = Album.find(params[:id])
		respond_with @album
	end

	def create
		@album = Album.new
		@album.name = params[:name]
		@album.genre = params[:genre]
		@album.release_date = Date.parse(params[:release_date]) unless params[:release_date].nil?
		@album.description = params[:description]
		@album.save
		respond_with @album
	end

	def update
		@album = Album.find(params[:id])
		@album.name = params[:name] unless params[:name].nil?
		@album.genre = params[:genre] unless params[:genre].nil?
		@album.release_date =Date.parse(params[:release_date]) unless params[:release_date].nil?
		@album.description = params[:description] unless params[:description].nil?
		@album.save
		respond_with @album
	end

	def destroy
		@album = Album.find(params[:id])
		@album.destroy
		respond_with @album
	end
end
