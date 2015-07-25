class Goal
  def get_goals (documentData)
    goalsData = {}
    documentData.keys.each do |key|
      if key.start_with?("PearlUserGoals")
        goalsData[key] = documentData[key]
      end
    end
    return goalsData
  end

end
