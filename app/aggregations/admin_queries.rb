# require_relative '../mongo_connection'
# require "awesome_print"

class Admin_Queries
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
							project_id: "$project_id",
							project_name: "$project_info.path_with_namespace"
							}}
							])
	end
end

# Testing Code
# m = Mongo_Connection.new("localhost", 27017, "GitLab", "Issues_Time_Tracking") 
# output = Admin_Queries.new(m)

# ap output.get_downloads