# Define factory for creating a valid user
FactoryGirl.define do
  factory :user do
    email  "come@me.bro"
    uid  "come@me.bro"
    password "12345678"
    provider "email"
  end

end