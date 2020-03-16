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

# put your API credentials here (found on your Twilio dashboard)
# put your API credentials here (found on your Twilio dashboard)
account_sid = ENV[TWILIO_ACCOUNT_SID]
auth_token = ENV[TWILIO_AUTH_TOKEN]

# set up a client to talk to the Twilio REST API
client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)


client.messages.create(
 from: "+19723629530", 
 to: "+18479897160",
 body: "Hey KIEI 451!"
)


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
#    @users_table = users_table
    view "plant"
end

get "/plants/:plant_id/uniqueplant/new" do
    puts "params: #{params}"

    @plant = plant_data_table.where(plant_id: params[:plant_id]).to_a[0]
    view "new_plant"
end

get "/plants/:plant_id/uniqueplant/create" do
    puts params
    @plant = plant_data_table.where(plant_id: params["plant_id"]).to_a[0]
    unique_plants_table.insert(plant_id: params["plant_id"],
                       user_id: session["user_id"],
                       latitude: params["latitude"],
                       longitude: params["longitude"],
                       plant_title: @plant[:plant_title])
    view "create_plant"
end

# display the signup form (aka "new")
get "/users/new" do
    view "new_user"
end

# receive the submitted signup form (aka "create")
post "/users/create" do
    puts "params: #{params}"

    # if there's already a user with this email, skip!
    existing_user = users_table.where(email: params["email"]).to_a[0]
    if existing_user
        view "error"
    else
        users_table.insert(
            name: params["name"],
            email: params["email"],
            password: BCrypt::Password.create(params["password"])
        )

        redirect "/logins/new"
    end
end

# display the login form (aka "new")
get "/logins/new" do
    view "new_login"
end

# receive the submitted login form (aka "create")
post "/logins/create" do
    puts "params: #{params}"

    # step 1: user with the params["email"] ?
    @user = users_table.where(email: params["email"]).to_a[0]

    if @user
        # step 2: if @user, does the encrypted password match?
        if BCrypt::Password.new(@user[:password]) == params["password"]
            # set encrypted cookie for logged in user
            session["user_id"] = @user[:id]
            redirect "/"
        else
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end
end

# logout user
get "/logout" do
    # remove encrypted cookie for logged out user
    session["user_id"] = nil
    redirect "/logins/new"
end

# post "/users/create" do
#     puts params
#     hashed_password = BCrypt::Password.create(params["password"])
#     users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
#     view "create_user"
# end   

# get "/logins/new" do
#     view "new_login"
# end

# post "/logins/create" do
#     user = users_table.where(email: params["email"]).to_a[0]
#     puts BCrypt::Password::new(user[:password])
#     if user && BCrypt::Password::new(user[:password]) == params["password"]
#         session["user_id"] = user[:id]
#         @current_user = user
#         view "create_login"
#     else
#         view "create_login_failed"
#     end
# end

# get "/logout" do
#     session["user_id"] = nil
#     @current_user = nil
#     view "logout"
# end