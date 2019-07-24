#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:fastfoodrecall.db"

class Shop < ActiveRecord::Base
  has_many :recalls, dependent: :destroy
end

class Recall < ActiveRecord::Base
  belongs_to :shop
  validates :comment, presence: true
  validates :rating, presence: true
end

class User < ActiveRecord::Base
  validates :name, presence: true
  validates :email, presence: true
  validates :password, presence: true
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

