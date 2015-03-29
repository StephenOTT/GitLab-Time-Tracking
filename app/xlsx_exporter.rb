# require 'mongo'

# require 'awesome_print'
# require_relative 'mongo_connection'

require 'axlsx'

class XLSXExporter
	def initialize(mongoConnection)
		@mongoConnection = mongoConnection
	end

	# include Mongo

	# def initialize(mongoConnection)
	# 	# MongoDB Database Connect
	# 	@client = MongoClient.new(url, port)

	# 	@db = @client[dbName]

	# 	@collTimeTracking = @db[collName]
	# end

	# def aggregate(input1)
		
	# 	@collTimeTracking.aggregate(input1)

	# end

	def generateXLSX(issuesData, milestoneData)

		Axlsx::Package.new do |p|
		  p.workbook.add_worksheet(:name => "Issues") do |sheet|
			sheet.add_row issuesData.first.keys
		    
		    issuesData.each do |hash|
				sheet.add_row hash.values
		  	end

		  end
		  p.workbook.add_worksheet(:name => "Milestones") do |sheet|
			if milestoneData.empty? == false
				sheet.add_row milestoneData.first.keys
			    
			    milestoneData.each do |hash|
					sheet.add_row hash.values
			  	end

			  elsif milestoneData.empty? == true
			  	sheet.add_row ["No Milestone Data"]
			  end
		  end

		  return p.to_stream
		end
	end

	def get_all_issues_time
		# TODO add filtering and extra security around query
		totalIssueSpentHoursBreakdown = @mongoConnection.aggregate([
			# { "$match" => { project_id: projectID }},

			{ "$unwind" => "$comments" },
			{"$project" => {_id: 0,
							project_id: 1, 
							id: 1,
							iid: 1,
							type: "$comments.time_tracking_data.type",
							milestone_number: "$milestone.iid",
							milestone_title: "$milestone.title",
							milestone_budget_comment: "$milestone.milestone_budget_data.budget_comment",
							milestone_state: "$milestone.state",
							milestone_due_date: "$milestone.due_date",
							issue_title: "$title",
							state: 1,
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

	def get_all_milestone_budgets
		# TODO add filtering and extra security around query
		totalMileStoneBudgetHoursBreakdown = @mongoConnection.aggregate([
			# { "$match" => { project_id: projectID }},

			# { "$unwind" => "$comments" },
			{"$project" => {_id: 0,
							project_id: 1, 
							id: 1,
							iid: 1,
							type: "$milestone.milestone_budget_data.type",
							milestone_number: "$milestone.iid",
							milestone_title: "$milestone.title",
							milestone_budget_comment: "$milestone.milestone_budget_data.budget_comment",
							milestone_state: "$milestone.state",
							milestone_due_date: "$milestone.due_date",
							milestone_budget_duration: "$milestone.milestone_budget_data.duration",
							}},
			{ "$group" => {_id: { 
							type: "$type",
							milestone_number: "$milestone_number",
							project_id: "$project_id", 
							id: "$id",
							iid: "$iid",
							milestone_number: "$milestone_number",
							milestone_title: "$milestone_title",
							milestone_budget_comment: "$milestone_budget_comment",
							milestone_state: "$milestone_state",
							milestone_due_date: "$milestone_due_date",
							milestone_budget_duration: "$milestone_budget_duration",
			}}}

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
		output = []
		totalMileStoneBudgetHoursBreakdown.each do |x|
			output << x["_id"]
		end
		return output
	end


end

# date = "2015-03-24T21:47:04.266Z"
# covert =  DateTime.strptime(date, '%Y-%m-%dT%H:%M:%S%z').to_time.utc
# puts convert
# Testing Code
# m = CSVExporter.new("localhost", 27017, "GitLab", "Issues_Time_Tracking")

# m = Mongo_Connection.new("localhost", 27017, "GitLab", "Issues_Time_Tracking") 
# csv = CSVExporter.new(m)
# export1 = csv.get_all_issues_time
# export2 = csv.get_all_milestone_budgets
# csv.generateCSV(export1, export2)

# ap export.get_all_milestone_budgets
# ap export

# CSV.open("data.csv", "wb") do |csv|
#   csv << export.first.keys # adds the attributes name on the first line
#   export.each do |hash|
#     csv << hash.values
#   end
# end
