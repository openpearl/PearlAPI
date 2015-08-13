require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:validUser) { create :user }
  it "has a valid factory" do
    expect(validUser).to be_valid
  end

  let(:userBuilder) { build :user }
  describe "email" do
    it "cannot be blank" do
      userBuilder.email = nil
      expect(userBuilder).to be_invalid
    end

    it "must be well-formed" do
      userBuilder.email = "come@mebro"
      expect(userBuilder).to be_invalid
    end

    it "must be unique" do
      expect(userBuilder.email).to be == (validUser.email)
      expect(userBuilder).to be_invalid
    end
  end

  describe "password" do
    it "cannot be blank" do
      user = build(:user, password: nil)
      expect(user).to be_invalid
    end

    it "must be at least 8 characters long" do
      user = build(:user, password: "1234567")
      expect(user).to be_invalid
    end
  end

end
