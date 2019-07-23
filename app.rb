#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:leprozoriumhq.db"

class Post < ActiveRecord::Base
	has_many :comments, dependent: :destroy
	validates :name, presence: true
	validates :content, presence: true
end

class Comment < ActiveRecord::Base
	belongs_to :post
	validates :content, presence: true
end

get '/' do
	@results = Post.all.order "id DESC"
	erb :index
end

get '/new' do
	@p = Post.new
  	erb :new
end

post '/new' do
	@p = Post.new params[:post]

	if @p.save
		redirect '/'
	else 
		@error = @p.errors.full_messages.first		
	end
	 	
  	erb :new
end

get '/detales/:post_id' do
	@post = Post.find params[:post_id]	
	
	@comments = @post.comments.all.order "id DESC"

	erb :detales
end

post '/detales/:post_id' do
	@post = Post.find params[:post_id]
	@comment = @post.comments.new params[:comment]
	@comments = @post.comments.all.order "id DESC"

	if !@comment.save
		@error = @comment.errors.full_messages.first
	end

	erb :detales
end

