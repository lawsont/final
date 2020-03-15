# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

plant_data_table = DB.from(:plant_data)
unique_plants_table = DB.from(:plant_data)
users_table = DB.from(:plant_data)

get "/" do
    puts plant_data_table.all
    @plants = plant_data_table.all 
    view "home"
end

get '/plants/:plant_id' do
    puts "params: #{params}"

    pp plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    @plant = plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    view "plant"
end

# this works but need to figure out how to submit to a new page

get "/plants/:plant_id/uniqueplant/new" do
    puts "params: #{params}"

    @plant = plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    view "new_plant"
end