require 'gitlab'
# require 'mongo'
require_relative 'issues'
require_relative 'milestones'
require_relative 'mongo_connection'
# require 'awesome_print'
# require 'secure_random'
# require 'time'

class GitLab_Downloader

	def initialize(gitlabURL, private_token)
		@glClient = Gitlab.client(endpoint: gitlabURL, private_token: private_token)
	end

	# Exposes the GitLab Client for easier access from the object
	def glClient
		@glClient
	end

        # Get user pojects
	def user_projects
		p = @glClient.projects({ "per_page" => 100 })
		p.each do |x|
			x = x.to_h
		end
		return p
	end


	def add_admin_records
		creationTime = Time.now
		creationUser = @glClient.user.to_h

		# TODO use a variable from when this class is inilized to get the URL.
		# TODO make the enpoint that is displaed to the user more "Friendly" aka drop /api/v3.
		gitlabEndpoint = ENV["GITLAB_ENDPOINT"] + (ENV['ENDPOINT_API_ADDRESS'] || "/api/v3")
		downloadID = SecureRandom.uuid

		return adminRecords = { "download_timestamp" => creationTime,
								"downloaded_by_user" => creationUser["username"],
								"downloaded_by_user_id" => creationUser["id"],
								"gitlab_endpoint" => gitlabEndpoint,
								"download_id" => downloadID
								}
	end

	def downloadIssuesAndComments(projectID)
		projectInfo = @glClient.project(projectID)
		projectInfo = projectInfo.to_h

		admin_info = add_admin_records
		
		issuePageNum = 1
		issues = @glClient.issues(projectID, :per_page=>100, :page=>issuePageNum)
		issues2 = []
		while issues.length > 0  do

			# Iterates through each issue and get the notes and merges the notes into the issue hash.
			issues.each do |x|
				x = x.to_h	# Converts the ObjectifiedHash that is returned by GitLab into a Ruby Hash
				
				x["created_at"] = DateTime.strptime(x["created_at"], '%Y-%m-%dT%H:%M:%S.%L%z').to_time.utc
				x["updated_at"] = DateTime.strptime(x["updated_at"], '%Y-%m-%dT%H:%M:%S.%L%z').to_time.utc

				commentPageNum = 1
				issueComments = @glClient.issue_notes(x["project_id"], x["id"], :per_page=>100, :page=>commentPageNum)	# Gets the notes for the current issue


				if issueComments.length > 0	# If there are notes in the issue then...
					comments2 = []	# Array used to hold comments with time tracking information.


					while issueComments.length > 0  do  # Loop used to control api pagination
						issueComments.each do |y|	# For Each Comment...
							y = y.to_h	# Convert from ObjectifiableHash to Ruby Hash

							y["created_at"] = DateTime.strptime(y["created_at"], '%Y-%m-%dT%H:%M:%S.%L%z').to_time.utc

							# Parses each comment for Time Tracking Information. Then merges back into the Comment Hash
							timeTrack = Gl_Issue.process_comment(y)
							if timeTrack != nil	 # If Time Tracking data was found for the Comment then....
								y = y.merge(timeTrack) # Merge time tracking hash into Comment Hash

								comments2 << y   # Add the merged hash into the Comment2 Array which holds comments that have time tracking information
							end
						end

						# Part of the pagination process to go through as many pages of comments that may exist for the current issue
						commentPageNum += 1
						issueComments = @glClient.issue_notes(x["project_id"], x["id"], :per_page=>100, :page=>commentPageNum)	# Gets the notes for the current issue
					end

					# if there are comments with time tracking information then....
					if comments2.length > 0
											# If there is milestone data then....
						if x["milestone"] != nil
							x["milestone"]["created_at"] = DateTime.strptime(x["milestone"]["created_at"], '%Y-%m-%dT%H:%M:%S.%L%z').to_time.utc
							x["milestone"]["updated_at"] = DateTime.strptime(x["milestone"]["updated_at"], '%Y-%m-%dT%H:%M:%S.%L%z').to_time.utc
							
							if x["milestone"]["due_date"] != nil
								x["milestone"]["due_date"] = DateTime.strptime(x["milestone"]["due_date"], '%Y-%m-%d').to_time.utc
							end


							milestoneBudgetTrack = Gl_Milestone.process_milestone(x["milestone"])	# Process the milestone data for budget tracking information.
							if milestoneBudgetTrack != nil
								x["milestone"]["milestone_budget_data"] = milestoneBudgetTrack
							end
						end

						x["project_info"] = projectInfo

						x["admin_info"] = admin_info
						x["comments"] = comments2 	# Merges the comments/notes into the main Issues Hash for each issue

						issues2 << x
					end
				end
			end

			issuePageNum += 1
			issues = @glClient.issues(projectID, :per_page=>100, :page=>issuePageNum)
		end
	return issues2
	end # End of Method
end # End of Class


# class Mongo_Connection

# 	include Mongo

# 	def initialize(url, port, dbName, collName)
# 		# MongoDB Database Connect
# 		@client = MongoClient.new(url, port)

# 		@db = @client[dbName]

# 		@collTimeTracking = @db[collName]
# 	end

# 	def clear_mongo_collections
# 		@collTimeTracking.remove
# 	end

# 	def putIntoMongoCollTimeTrackingCommits(mongoPayload)
# 		@collTimeTracking.insert(mongoPayload)
# 	end


# end

# Testing Code
# m = Mongo_Connection.new("localhost", 27017, "GitLab-TimeTracking", "TimeTrackingCommits")
# m.clear_mongo_collections

# g = GitLab_Downloader.new("https://gitlab.com/api/v3", "GITLAB-TOKEN")
# dog = g.downloadIssuesAndComments(153287)
# dog = g.glClient.issue_notes(153287, 162495, :per_page=>1)	
# response = http_response_for(dog)
# ap dog
# issuesWithComments = g.downloadIssuesAndComments
# m.putIntoMongoCollTimeTrackingCommits(issuesWithComments)