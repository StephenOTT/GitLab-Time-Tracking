require_relative 'helpers'
require_relative 'milestone_budget'

module Gl_Milestone

	def self.process_milestone(milestoneDetail)

		milestoneDescription = milestoneDetail["description"]
		recordCreationDate = Time.now.utc

		# cycles through each comment and returns time tracking 
		# checks to see if there is a time comment in the body field
		isBudgetComment = Helpers.budget_comment?(milestoneDescription)
		if isBudgetComment == true
			# if true, the body field is parsed for time comment details
			parsedBudget = Gl_Milestone_Budget.process_budget_description_for_time(milestoneDescription)
		
			if parsedBudget != nil

				# return output = {"milestone_budget_tracking_data" => parsedBudget}
				return output = parsedBudget
			else
				return output = nil
			end

		end
	end
end