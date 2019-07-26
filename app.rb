#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'bcrypt'

set :database, "sqlite3:fastfoodrecall.db"
enable :sessions

class Shop < ActiveRecord::Base
  has_many :recalls, dependent: :destroy
  validates_uniqueness_of :name
end

class Recall < ActiveRecord::Base
  belongs_to :shop
  validates :rating, presence: true
  validates :comment, presence: true, unless: :perfectly?

  def perfectly?
    rating == 5
  end
end

class User < ActiveRecord::Base
  include BCrypt

  validates :name, presence: true
  validates :email, presence: true
  validates :password_hash, presence: true
  validates_uniqueness_of :email

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end

get '/' do
  @shops = Shop.all
  erb :index
end

get '/detales/:shop_id' do
  @shop = Shop.find(params[:shop_id])  
  @recall = @shop.recalls.new
  @recalls = @shop.recalls.all.order("id DESC")
  erb :detales
end

post '/detales/:shop_id' do
  @shop = Shop.find(params[:shop_id])
  @recall = @shop.recalls.new(params[:recall])
  @recalls = @shop.recalls.all.order("id DESC")

  if session['user_id']
    if @recall.save
      @shop.rating = (@shop.recalls.inject(0.0) { |sum, recall| sum + recall.rating } / @shop.recalls.size).round(1)
      @shop.save
    else
      @error = @recall.errors.full_messages.first
    end
  else
    @error = "Сначала надо авторизоваться"
  end

  erb :detales
end

get '/register' do
  erb :register
end

post '/register' do
  @user = User.new(params[:user])
  @user.password = params[:password]
  if @user.save!
    redirect '/login'
  else
    @error = @user.errors.full_messages.first
  end
  erb :login
end


get '/login' do
  erb :login
end

post '/login' do
  @user = User.find_by_email(params[:email])

  unless @user
    @error = "Нет пользователя с таким E-mail"
    erb :login
  else
    if @user.password == params[:password]
      session['user_id'] = @user.id
      redirect '/'
    else
      @error = "Неправильный пароль"
    end
    erb :login
  end

end

get '/logout' do
  session.clear
  redirect '/'
end
