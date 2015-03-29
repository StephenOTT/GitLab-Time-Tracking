require_relative '../mongo_connection'
require "awesome_print"


class Issue_Stat_Queries
	def initialize(mongoConnection)
		@mongoConnection = mongoConnection
	end

	def get_downloads
		# TODO add filtering and extra security around query
		output = @mongoConnection.aggregate([
			# { "$match" => { project_id: projectID }},

			{"$project" => {_id: 0,
							download_id: "$admin_info.download_id", 
							download_date: "$admin_info.download_timestamp",
							downloaded_by: "$admin_info.downloaded_by_user",
							download_endpoint: "$admin_info.gitlab_endpoint",
							project_id: "$project_id"
							}}
							])
	end




	def get_issues_time
			# TODO add filtering and extra security around query
			output = @mongoConnection.aggregate([
				# { "$match" => { project_id: projectID }},

				{ "$unwind" => "$comments" },
				{"$project" => {_id: 0,
								project_id: 1, 
								issue_id: "$id",
								issue_number: "$iid",
								type: { "$ifNull" => [ "$comments.time_tracking_data.type", nil ] }, 
								milestone_number: { "$ifNull" => [ "$milestone.iid", nil ] },
								milestone_title: { "$ifNull" => [ "$milestone.title", nil ] },
								milestone_budget_comment: { "$ifNull" => [ "$milestone.milestone_budget_data.budget_comment", nil ] },
								milestone_state: { "$ifNull" => [ "$milestone.state", nil ] },
								milestone_due_date: { "$ifNull" => [ "$milestone.due_date", nil ] },
								issue_title: "$title",
								issue_state: "$state",
								issue_author: "$author.username",
								comment_id: "$comments.id",
								time_track_duration: "$comments.time_tracking_data.duration",
								time_track_non_billable: "$comments.time_tracking_data.non_billable",
								time_track_work_date: "$comments.time_tracking_data.work_date",
								time_track_time_comment: "$comments.time_tracking_data.time_comment",
								time_track_work_date_provided: "$comments.time_tracking_data.work_date_provided",
								time_track_work_logged_by: "$comments.time_tracking_data.work_logged_by"}},			
				# { "$unwind" => "$comments.time_tracking_data" },


				# { "$match" => { "comments.time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
				# { "$group" => { _id: {
				# 				project_id: "$project_id",
				# 				id: "$id",
				# 				iid: "$iid",
				# 				title: "$title",
				# 				state: "$state",
				# 				issue_author: "$author.username",
				# 				comment_id: "$comment.id",
				# 				comment_author: "$comment.author.username",
				# 				time_track_duration: "$comment.time_tracking_data.duration",
				# 				time_track_non_billable: "$comment.time_tracking_data.non_billable",
				# 				time_track_work_date: "$comment.time_tracking_data.work_date",
				# 				time_track_time_comment: "$comment.time_tracking_data.time_comment",
				# 				},

				# 				}}
								])
			# output = []
			# totalIssueSpentHoursBreakdown.each do |x|
			# 	x["_id"]["time_duration_sum"] = x["time_duration_sum"]
			# 	x["_id"]["time_comment_count"] = x["time_comment_count"]
			# 	output << x["_id"]
			# end
			# return output
	end
	

end

# Testing Code
m = Mongo_Connection.new("localhost", 27017, "GitLab", "Issues_Time_Tracking") 
output = Issue_Stat_Queries.new(m)

ap output.get_issues_time

