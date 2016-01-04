# require_relative 'labels_processor'
require_relative 'helpers'
# require_relative 'issue_budget'
require_relative 'issue_time'
# require_relative '../gh_issue_task_aggregator'
# require 'pp'

module Gl_Issue

        def self.process_description(issue) 
            includesPointsInfo = Helpers.points_message?(issue['description'])

            if includesPointsInfo
                parsedPoints = Gl_Issue_Time.process_issue_message_for_points(issue);
                if parsedPoints != nil
                    issue['points'] = parsedPoints['points'].to_i;
                    issue['points_comment'] = parsedPoints['points_comment'];
                    issue['points_points'] = parsedPoints['points'];
                else
                    issue['points'] = 0;
                end
            else
                issue['points'] = 0;
            end

            return issue
        end

	def self.process_comment(issueComment)
		bodyField = issueComment["body"]
		
		commentsTime = []

		# cycles through each comment and returns time tracking 
		# issueComments.each do |x|
			# checks to see if there is a time comment in the body field
			isTimeComment = Helpers.time_comment?(bodyField)
			isBudgetComment = Helpers.budget_comment?(bodyField)
			
			if isTimeComment == true
				# if true, the body field is parsed for time comment details
				parsedTime = Gl_Issue_Time.process_issue_comment_for_time(issueComment)
				if parsedTime != nil
					# assuming results are returned from the parse (aka the parse was preceived 
					# by the code to be sucessful, the parsed time comment details array is put into
					# the commentsTime array)
					return output = {"time_tracking_data" => parsedTime}
				else
					return output = nil
				end
                        end
			# Buget Handling
			#elsif isBudgetComment == true
			#	parsedBudget = Gh_Issue_Budget.process_issue_comment_for_budget(issueComment)
			#	if parsedBudget != nil
			#		commentsTime << parsedBudget
			#	end
		# end # do not delete this 'end'.  it is part of issueComments do block

		# if commentsTime.empty? == false
		# 	return output = {
		# 		"time_tracking_commits" => commentsTime
		# 	}
		# elsif commentsTime.empty? == true
		# 	return output = {
		# 		"time_tracking_commits" => nil
		# 	}
		# end
	end
end
