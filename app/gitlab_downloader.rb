require 'gitlab'
# require 'mongo'
require_relative 'issues'
require_relative 'mongo_connection'

class GitLab_Downloader

	def initialize(gitlabURL, private_token)
		@glClient = Gitlab.client(endpoint: gitlabURL, private_token: private_token)
	end

	# Exposes the GitLab Client for easier access from the object
	def glClient
		@glClient
	end

	def downloadIssuesAndComments(projectID)
		# issues = @glClient.issues(153287)
		issues = @glClient.issues(projectID)
		issues2 = []
		# Iterates through each issue and get the notes and merges the notes into the issue hash.
		issues.each do |x|
			x = x.to_h	# Converts the ObjectifiedHash that is returned by GitLab into a Ruby Hash
			
			issueComments = @glClient.issue_notes(x["project_id"], x["id"])	# Gets the notes for the current issue
			if issueComments.length > 0
				comments2 = []
				issueComments.each do |y|
					y = y.to_h
					
					# Parses each comment for Time Tracking Information. Then merges back into the Comment Hash
					timeTrack = Gl_Issue.process_comment(y)
					if timeTrack != nil
						y = y.merge(timeTrack)
					

					comments2 << y
					end
				end


				x["comments"] = comments2 	# Merges the comments/notes into the main Issues Hash for each issue
				
				issues2 << x
			end
		end
		ap issues2
		issues2
	end
end

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

# g = GitLab_Downloader.new("https://gitlab.com/api/v3", "GITLAB-PRIVATE-TOKEN")

# issuesWithComments = g.downloadIssuesAndComments
# m.putIntoMongoCollTimeTrackingCommits(issuesWithComments)




