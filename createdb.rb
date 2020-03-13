# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :plant_data do
  primary_key :plant_id
  String :plant_title
  String :description, text: true
end
DB.create_table! :unique_plants do
  primary_key :unique_id
  foreign_key :plant_id
  foreign_key :user_id
  Numeric :latitude
  Numeric :longitude  
end
DB.create_table! :users do
  primary_key :user_id
  foreign_key :event_id
  String :name
  String :email
  String :email
  String :email
  Numeric :fav_plant_id_1
  Numeric :fav_plant_id_2
  Numeric :fav_plant_id_3
end

# Insert initial (seed) data
events_table = DB.from(:events)

events_table.insert(title: "Bacon Burger Taco Fest", 
                    description: "Here we go again bacon burger taco fans, another Bacon Burger Taco Fest is here!",
                    date: "June 21",
                    location: "Kellogg Global Hub")

events_table.insert(title: "Kaleapolooza", 
                    description: "If you're into nutrition and vitamins and stuff, this is the event for you.",
                    date: "July 4",
                    location: "Nowhere")
