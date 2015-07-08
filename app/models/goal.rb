class Goal < ActiveRecord::Base
  belongs_to :user

  def update(goal_params)
    goal_params.keys.each do |key|
      if self.has_attribute?(key)
        self[key] = goal_params[key]
      end
    end
    self.save
  end 
end
