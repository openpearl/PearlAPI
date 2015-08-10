class Goal
  def self.get_goals(documentData)
    goalsData = {}
    documentData.keys.each do |key|
      if key.start_with?("PearlUserGoals")
        goalsData[key] = documentData[key]
      end
    end
    return goalsData.with_indifferent_access
  end


  def self.get_goal_updates (tvGoals, goalUpdates)
    if goalUpdates["goals"].class == Array
      goalUpdates["goals"].each do |goal|
        goal_to_upate = goal["id"]
        tvGoals.each do |key,value|
          if not value["goals"][goal_to_upate].nil?
            value["goals"][goal_to_upate]["checked"] = goal["checked"]
          end
        end
      end
    else
      goal_to_upate = goalUpdates["goals"]["id"]
      tvGoals.each do |key,value|
        if not value["goals"][goal_to_upate].nil?
          value["goals"][goal_to_upate]["checked"] = goalUpdates["goals"]["checked"]
        end
      end
    end
    return tvGoals
  end

end
