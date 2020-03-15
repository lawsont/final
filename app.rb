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
unique_plants_table = DB.from(:unique_plants)
users_table = DB.from(:users)

get "/" do
    puts unique_plants_table.all
    @plants = unique_plants_table.all.to_a
    view "home"
end

get '/plants/:plant_id' do
    puts "params: #{params}"

    pp plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    @plant = plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    pp unique_plants_table.where(plant_id: params[:plant_id]).to_a[0]
    @plant_location = unique_plants_table.where(plant_id: params[:plant_id]).to_a[0] # I pulled this in successfully to plant.erb but it won't pull latitude for some reason
    view "plant"
end

# this works but need to figure out how to submit to a new page

get "/plants/:plant_id/uniqueplant/new" do
    puts "params: #{params}"

    @plant = plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    view "new_plant"
end

# copied in - need to edit - also how do we get the form to submit and what do I put in the names in orange below?

get "/plants/:plant_id/uniqueplant/create" do
    puts params
    @event = events_table.where(id: params["id"]).to_a[0]
    unique_plants_table.insert(plant_id: params["plant_id"],
                       user_id: session["user_id"],
                       latitude: params["going"],
                       comments: params["comments"])
    view "create_rsvp"
end
