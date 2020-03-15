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
  String :lat_long
end
DB.create_table! :unique_plants do
  primary_key :unique_id
  foreign_key :plant_id
  foreign_key :user_id
  String :plant_title
  Numeric :latitude
  Numeric :longitude  
end
DB.create_table! :users do
  primary_key :user_id
  foreign_key :event_id
  String :name
  String :email
  String :password
  Numeric :fav_plant_id_1
  Numeric :fav_plant_id_2
  Numeric :fav_plant_id_3
end

# Insert initial (seed) data
plant_data_table = DB.from(:plant_data)

plant_data_table.insert(plant_title: "Hydrangea", 
                    description: "Hydrangeas have beautiful blooms of little colorful flowers. They bloom all summer long.",
                    lat_long: "41.917782, -87.675539")

plant_data_table.insert(plant_title: "Hosta", 
                    description: "Hosta is the tried and true garden staple for the midwesterner. There are thousands of varieties with varying shades of green foliage.",
                    lat_long: "41.917725, -87.675467")

plant_data_table.insert(plant_title: "Coneflower", 
                    description: "Coneflowers have stunning flowers with a big eye in the middle. They come in deep oranges, reds and yellows.",
                    lat_long: "41.917712, -87.675576")

plant_data_table.insert(plant_title: "Maple Tree", 
                    description: "The most common tree in the midwest, you'll find this along streets, in parks and homes. They provide ample shade. ",
                    lat_long: "41.917577, -87.675234")

plant_data_table.insert(plant_title: "Viburnum", 
                    description: "Viburnum is a shrub that has unique leaves and many flowering branches. It has many benefits including berries in the late fall.",
                    lat_long: "41.917532, -87.675229")

unique_plants_table = DB.from(:unique_plants)

unique_plants_table.insert(plant_id: 1, 
                    plant_title: "Hydrangea",
                    latitude: 41.917782,
                    longitude: -87.675539,
                    user_id: 1)

unique_plants_table.insert(plant_id: 2, 
                    plant_title: "Hosta",
                    latitude: 41.917725,
                    longitude: -87.675576,
                    user_id: 1)

unique_plants_table.insert(plant_id: 3, 
                    plant_title: "Coneflower",
                    latitude: 41.917712,
                    longitude: -87.675576,
                    user_id: 1)

unique_plants_table.insert(plant_id: 4, 
                    plant_title: "Maple Tree",
                    latitude: 41.917577,
                    longitude: -87.675234,
                    user_id: 1)

unique_plants_table.insert(plant_id: 5, 
                    plant_title: "Viburnum",
                    latitude: 41.917532,
                    longitude: -87.675229,
                    user_id: 1)

unique_plants_table.insert(plant_id: 3, 
                    plant_title: "Coneflower",
                    latitude: 41.917579,
                    longitude: -87.675212,
                    user_id: 1)     
                    
unique_plants_table.insert(plant_id: 3, 
                    plant_title: "Coneflower",
                    latitude: 41.917534,
                    longitude: -87.675222,
                    user_id: 1)                               

users_table = DB.from(:users)

users_table.insert(name: "Lawson Thalmann",
                    email: "lawson.thalmann@kellogg.northwestern.edu",
                    password: "lawson123",
                    fav_plant_id_1: 1,
                    fav_plant_id_2: 2,
                    fav_plant_id_3: 3)


