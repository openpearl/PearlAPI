require 'rails_helper'

RSpec.describe Goal, type: :model do

  describe '.get_goals' do
    context 'when given empty data hash' do
      mockUserData = {}.with_indifferent_access
      it 'returns an empty hash' do
        goalData = Goal.get_goals(mockUserData)
        expect(goalData).to be == ({})
      end
    end

    context 'when given hash without goals' do
      mockUserData = {
        "HKQuantityTypeIdentifierStepCount": [
          {
            "UUID": "EAE2C7E9-2526-4E87-881B-B91B583C56CC",
            "endDate": 1123581321,
            "quantity": 1337,
            "sourceName": "Health",
            "sourceBundleId": "com.apple.Health",
            "startDate": 1123581321
          }
        ]
      }.with_indifferent_access
      it 'returns an empty hash' do
        goalData = Goal.get_goals(mockUserData)
        expect(goalData).to be == ({})
      end
    end

    context 'when given hash with goals' do
      mockUserData = {
        "PearlUserGoalsPhysical": {
          "name": "Physical",
          "description": "Physical health refers to your ability to maintain a physical condition which allows you to enjoy a healthy quality of life without undue fatigue or stress",
          "goals": {
            "get_fit": {
              "id": "get_fit",
              "name": "Get fit",
              "checked": false
            }
          }
        },
        "HKQuantityTypeIdentifierStepCount": [
          {
            "UUID": "EAE2C7E9-2526-4E87-881B-B91B583C56CC",
            "endDate": 1123581321,
            "quantity": 1337,
            "sourceName": "Health",
            "sourceBundleId": "com.apple.Health",
            "startDate": 1123581321
          }
        ]
      }.with_indifferent_access
      it 'returns a hash with only goals' do
        goalData = Goal.get_goals(mockUserData)
        expectedResult = {
          "PearlUserGoalsPhysical": {
            "name": "Physical",
            "description": "Physical health refers to your ability to maintain a physical condition which allows you to enjoy a healthy quality of life without undue fatigue or stress",
            "goals": {
              "get_fit": {
                "id": "get_fit",
                "name": "Get fit",
                "checked": false
              }
            }
          }
        }.with_indifferent_access
        expect(goalData).to be == (expectedResult)
      end
    end
  end

end
