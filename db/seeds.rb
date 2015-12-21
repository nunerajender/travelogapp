# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Location.count == 0
	Location.create([{ state: 'Kuala Lumpur - Selangor'} , { state: 'Langkawi' } , { state: 'Penang' }])
end

location = Location.first
Product.update_all("location_id = '#{location.id}'")