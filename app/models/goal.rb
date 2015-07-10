class Goal < ActiveRecord::Base
  belongs_to :user

  # Updates the user's goal(s).
  def update(goal_params)
    # For each key in goal_params, check to see if that key is a goal that matches a known goal in the goals settings.
    goal_params.keys.each do |key|
      # If the key is a goal in the goal settings, update the boolean "checked" value of the goal to match the one 
      # specified in goal_params
      if self.has_attribute?(key)
        values = JSON.parse(self[key])
        values["checked"] = goal_params[key]
        updatedValues = values.to_json
        self[key] = updatedValues
      end
    end
    self.save
  end 



  def as_json(options={})
    result = super(:except => [:id, :user_id, :created_at, :updated_at])
    result.keys.each do |key|
      result[key] = JSON.parse(result[key])
    end
    return result
  end
end
