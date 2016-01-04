# require_relative '../mongo_connection'
# require "awesome_print"


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

	def get_project_snapshot_info(downloadID)
		# TODO add filtering and extra security around query
		output = @mongoConnection.aggregate([
			# { "$match" => { project_id: projectID }},
			{"$limit" => 1},
			{"$project" => {_id: 0,
							admin_info: "$admin_info", 
							project_info: "$project_info",
							}}
							]).first
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

	def get_all_issues_time(downloadID)
		output = @mongoConnection.aggregate([
			# { "$match" => { downloaded_by_username: githubAuthInfo[:username], downloaded_by_userID: githubAuthInfo[:userID] }},
			# { "$unwind" => "$comments" },
			# { "$match" => { admin_info: {download_id: downloadID}}},
			{ "$unwind" => "$comments" },
			{"$project" => {_id: 0, 
							download_id: "$admin_info.download_id",
							project: "$project_info.path_with_namespace",
							issue_number: "$iid",
							issue_title: "$title",
							issue_state: "$state",
							duration: "$comments.time_tracking_data.duration"
							}},
			{ "$match" => {download_id: downloadID}},
			# { "$unwind" => "$comments" },
			
			{ "$group" => { _id: {
								project: "$project",
								# milestone_number: "$milestone_number",
								issue_number: "$issue_number",
								issue_title: "$issue_title",
								issue_state: "$issue_state",
								},
								time_duration_sum: { "$sum" => "$duration" },
								time_comment_count: {"$sum" => 1}
								}
							},
			# { "$match" => {download_id: downloadID}},
							])
		output.each do |x|
			x["_id"]["time_duration_sum"] = x["time_duration_sum"]
			x["_id"]["time_comment_count"] = x["time_comment_count"]
		end
		return output.map { |e| e["_id"]  }
	end




	def get_issues_for_milestone(downloadID, milestoneNumber)
		output = @mongoConnection.aggregate([
			{ "$unwind" => {path: "$comments", preserveNullAndEmptyArrays: true }},
			{"$project" => {_id: 0, 
							download_id: "$admin_info.download_id",
							# project: "$project_info.path_with_namespace",
							issue_number: "$iid",
							issue_title: "$title",
							issue_state: "$state",
                                                        issue_comment_flag: { "$cond" => [ "$comments.time_tracking_data", 1, 0 ] },
                                                        issue_points: "$points",
							comment_duration: "$comments.time_tracking_data.duration",
							comment_time_comment: { "$ifNull" => [ "$comments.time_tracking_data.time_comment", nil ] },
							milestone_number: { "$ifNull" => [ "$milestone.iid", nil ] },
							}},
			{ "$match" => {download_id: downloadID}},
			{ "$match" => {milestone_number: milestoneNumber}},
			{ "$group" => { _id: {
								# project: "$project",
								issue_number: "$issue_number",
								issue_title: "$issue_title",
								issue_state: "$issue_state",
								},
								time_duration_sum: { "$sum" => "$comment_duration" },
								time_comment_count: {"$sum" => "$issue_comment_flag"}
								}
							},
							])
		output.each do |x|
			x["_id"]["time_duration_sum"] = x["time_duration_sum"]
			x["_id"]["time_comment_count"] = x["time_comment_count"]
		end
		return output.map { |e| e["_id"]  }
	end

	def get_milestones(downloadID)
		output = @mongoConnection.aggregate([
			# { "$unwind" => "$comments" },
			{"$project" => {_id: 0, 
							download_id: "$admin_info.download_id",
							project: "$project_info.path_with_namespace",
							# issue_number: "$iid",
							# issue_title: "$title",
							# issue_state: "$state",
							# comment_duration: "$comments.time_tracking_data.duration",
							# comment_time_comment: { "$ifNull" => [ "$comments.time_tracking_data.time_comment", nil ] },
							milestone_number: { "$ifNull" => [ "$milestone.iid", nil ] },
							milestone_title: { "$ifNull" => [ "$milestone.title", nil ] },
							milestone_budget_comment: { "$ifNull" => [ "$milestone.milestone_budget_data.budget_comment", nil ] },
							milestone_state: { "$ifNull" => [ "$milestone.state", nil ] },
							milestone_due_date: { "$ifNull" => [ "$milestone.due_date", nil ] },
							milestone_budget_duration: { "$ifNull" => [ "$milestone.milestone_budget_data.duration", nil ] },


							}},
			{ "$match" => {download_id: downloadID}},
			{ "$group" => { _id: {
								download_id: "$download_id",
								project: "$project",
								milestone_number: "$milestone_number",
								milestone_title: "$milestone_title",
								milestone_budget_comment: "$milestone_budget_comment",
								milestone_state: "$milestone_state",
								milestone_due_date: "$milestone_due_date",
								milestone_budget_duration: "$milestone_budget_duration"

								}}
							},
							])
		# output.each do |x|
		# 	x["_id"]["time_duration_sum"] = x["time_duration_sum"]
		# 	x["_id"]["time_comment_count"] = x["time_comment_count"]
		# end
		return output.map { |e| e["_id"]  }
	end

        def get_milestone_points(downloadID, milestoneNumber)
                output = @mongoConnection.aggregate([
                        {"$project" => {_id: 0, 
                                                        download_id: "$admin_info.download_id",
                                                        project: "$project_info.path_with_namespace",
                                                        issue_number: "$iid",
                                                        milestone_number: { "$ifNull" => [ "$milestone.iid", nil ] },
                                                        milestone_title: { "$ifNull" => [ "$milestone.title", nil ] },
                                                        milestone_budget_comment: { "$ifNull" => [ "$milestone.milestone_budget_data.budget_comment", nil ] },
                                                        milestone_state: { "$ifNull" => [ "$milestone.state", nil ] },
                                                        milestone_due_date: { "$ifNull" => [ "$milestone.due_date", nil ] },
                                                        milestone_budget_duration: { "$ifNull" => [ "$milestone.milestone_budget_data.duration", nil ] },
                                                        issue_points: { "$ifNull" => [ "$points", nil ] },


                                                        }},
                        { "$match" => {download_id: downloadID, milestone_number: milestoneNumber}},
                        { "$group" => { _id: {
                                                                download_id: "$download_id",
                                                                milestone_number: "$milestone_number",

                                                                },
                                                                points_total: { "$sum" => "$issue_points" },
                                                        }},
                                                        ])
                output.each do |x|
                        x["_id"]["points_total"] = x["points_total"]
                end
                return output.map { |e| e["_id"]  }.first
        end

	def get_milestone_sums(downloadID, milestoneNumber)
		output = @mongoConnection.aggregate([
			{ "$unwind" => "$comments" },
			{"$project" => {_id: 0, 
							download_id: "$admin_info.download_id",
							project: "$project_info.path_with_namespace",
							issue_number: "$iid",
							# issue_title: "$title",
							# issue_state: "$state",
							comment_duration: "$comments.time_tracking_data.duration",
							# comment_time_comment: { "$ifNull" => [ "$comments.time_tracking_data.time_comment", nil ] },
							milestone_number: { "$ifNull" => [ "$milestone.iid", nil ] },
							milestone_title: { "$ifNull" => [ "$milestone.title", nil ] },
							milestone_budget_comment: { "$ifNull" => [ "$milestone.milestone_budget_data.budget_comment", nil ] },
							milestone_state: { "$ifNull" => [ "$milestone.state", nil ] },
							milestone_due_date: { "$ifNull" => [ "$milestone.due_date", nil ] },
							milestone_budget_duration: { "$ifNull" => [ "$milestone.milestone_budget_data.duration", nil ] },
                                                        comment_points: { "$ifNull" => [ "$comments.points_tracking_data.points", nil ] },


							}},
			{ "$match" => {download_id: downloadID, milestone_number: milestoneNumber}},
			{ "$group" => { _id: {
								download_id: "$download_id",
								# project: "$project",
								milestone_number: "$milestone_number",
								# milestone_title: "$milestone_title",
								# milestone_budget_comment: "$milestone_budget_comment",
								# milestone_state: "$milestone_state",
								# milestone_due_date: "$milestone_due_date",
								# milestone_budget_duration: "$milestone_budget_duration",
								# comment_duration: "$comment_duration",

								},
								time_duration_sum: { "$sum" => "$comment_duration" },
								time_comment_count: {"$sum" => 1}
							}},
							])
		output.each do |x|
			x["_id"]["time_duration_sum"] = x["time_duration_sum"]
			x["_id"]["time_comment_count"] = x["time_comment_count"]
		end


                if output.length > 0
                    return output.map { |e| e["_id"]  }.first
                else
                    return { 'time_duration_sum' => 0, 'time_comment_count' => 0 };
                end
	end

end

# Testing Code
# m = Mongo_Connection.new("localhost", 27017, "GitLab", "Issues_Time_Tracking") 
# output = Issue_Stat_Queries.new(m)


# ap output.get_issues_time
# ap output.get_all_issues_time("abdd1c36-4cb0-4828-bbe0-34a1d679ca2f")
# ap output.get_issues_for_milestone("57a364cb-9fb2-423c-a1aa-72ede9934325", 1)
# ap output.get_milestones("8cec1dc7-2284-46d4-937b-b5ae937bf2c9", 1)
# ap output.get_milestone_sums("8cec1dc7-2284-46d4-937b-b5ae937bf2c9", 1)
# ap output.get_project_snapshot_info("8cec1dc7-2284-46d4-937b-b5ae937bf2c9")

