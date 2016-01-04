require 'chronic_duration'
require_relative 'accepted_emoji'

module Helpers

	def self.get_Issue_Budget_Emoji
		return Accepted_Time_Tracking_Emoji.accepted_issue_budget_emoji
	end
	def self.get_Issue_Time_Emoji
		return Accepted_Time_Tracking_Emoji.accepted_time_comment_emoji
	end
	def self.get_Milestone_Budget_Emoji
		return Accepted_Time_Tracking_Emoji.accepted_milestone_budget_emoji
	end
	def self.get_Non_Billable_Emoji
		return Accepted_Time_Tracking_Emoji.accepted_nonBillable_emoji
	end

        def self.get_Issue_Points_Emoji
            return Accepted_Time_Tracking_Emoji.accepted_issue_points_emoji
        end

	def self.get_duration(durationText)
		return ChronicDuration.parse(durationText)
	end

        def self.get_points(pointText) 
            return pointText
        end

	def self.get_time_work_date(parsedTimeComment)
		begin
			return Time.parse(parsedTimeComment).utc
		rescue
			return nil
		end
	end

	def self.parse_non_billable_time_comment(timeComment, timeEmoji, nonBillableEmoji)
		return timeComment.gsub("#{timeEmoji} #{nonBillableEmoji} ","").split(" | ")
	end

	def self.parse_billable_time_comment(timeComment, timeEmoji)
		return timeComment.gsub("#{timeEmoji} ","").split(" | ")
	end

        def self.parse_points_message(issueDescription, pointsEmoji)
            return issueDescription.
                split("\n").
                find{ |s| s[/^#{pointsEmoji}/] }.
                gsub("#{pointsEmoji} ","").
                split(" | ")
        end

	def self.get_time_commit_comment(parsedTimeComment)
		return parsedTimeComment.lstrip.gsub("\r\n", " ")
	end

	# Is it a budget comment?  Returns True or False
	def self.budget_comment?(commentBody)
		acceptedBudgetEmoji = Accepted_Time_Tracking_Emoji.accepted_milestone_budget_emoji

		acceptedBudgetEmoji.any? { |w| commentBody =~ /\A#{w}/ }
	end

	# Is the time Non-Billable? Returns True or False
	def self.non_billable?(commentBody)
		acceptedNonBilliableEmoji = Accepted_Time_Tracking_Emoji.accepted_nonBillable_emoji
		return acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }
	end

	# Is it a time comment?  Returns True or False
	def self.time_comment?(commentBody)
		acceptedClockEmoji = Accepted_Time_Tracking_Emoji.accepted_time_comment_emoji

		acceptedClockEmoji.any? { |w| commentBody =~ /\A#{w}/ }
	end

        # Is it a points comment?  Returns True or False
        def self.points_message?(commentBody)
                acceptedPointEmoji = Accepted_Time_Tracking_Emoji.accepted_issue_points_emoji
                acceptedPointEmoji.any? { |w| commentBody =~ /^#{w}/m }
        end


	# TODO Rebuild for GitLab
	# Gets the milestone ID number assigned to the issue
	def self.get_issue_milestone_number(milestoneDetails)
		if milestoneDetails != nil
			return milestoneDetails.attrs[:number]
		end
	end


	# Not sure what this is used for - TODO figure out why i wrote this
	def self.convertSecondsToDurationFormat(timeInSeconds, outputFormat)
		outputFormat = outputFormat.to_sym
		return ChronicDuration.output(timeInSeconds, :format => outputFormat, :keep_zero => true)
	end

end
