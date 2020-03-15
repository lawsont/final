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
    puts plant_data_table.all
    @plants = plant_data_table.all.to_a
    view "home"
end

get '/plants/:plant_id' do
    puts "params: #{params}"

    pp plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    @plant = plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    pp unique_plants_table.where(plant_id: params[:plant_id]).to_a[0]
    @plant_location = unique_plants_table.where(plant_id: params[:plant_id]).all.to_a
    @plant_instances = unique_plants_table.where(plant_id: @plant[:plant_id]).all.to_a
    @plant_lat_long = unique_plants_table.where(plant_id: @plant[:plant_id]).all.to_a
    view "plant"
end

get "/plants/:plant_id/uniqueplant/new" do
    puts "params: #{params}"

    @plant = plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    view "new_plant"
end

# copied in - need to edit - also how do we get the form to submit and what do I put in the names in orange below?

get "/plants/:plant_id/uniqueplant/create" do
    puts params
    @plant = plant_data_table.where(plant_id: params["plant_id"]).to_a[0]
    unique_plants_table.insert(plant_id: params["plant_id"],
                       user_id: 1,         # not sure what to do here... session["user_id"],
                       latitude: params["latitude"],
                       longitude: params["longitude"],
                       plant_title: @plant[:plant_title])
    view "create_plant"
end

get "/users/new" do 
    view "new_user"
end

get "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end   

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end