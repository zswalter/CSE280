# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

require 'faker'

fake_password = "f00bar"

User.delete_all


100.times do
  
  User.create!( :firstname => Faker::Name::first_name,
                :lastname => Faker::Name::last_name,
                :email =>Faker::Internet::email,
                :address => Faker::Address::street_address,
                :phonenumber => Faker::PhoneNumber::phone_number,
                :city => Faker::Address::city,
                :state => Faker::Address::state_abbr,
                :postalcode => Faker::Address::zip_code,
                :password => fake_password,
                :password_confirmation => fake_password )

end

puts User.count.to_s + ' users loaded successfully.'
