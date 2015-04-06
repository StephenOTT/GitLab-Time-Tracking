require 'mongo'

class Mongo_Connection

	include Mongo

	def initialize(url, port, dbName, collName)
		# MongoDB Database Connect
		@client = MongoClient.new(url, port)

		@db = @client[dbName]

		@collTimeTracking = @db[collName]
	end

	def clear_mongo_collections
		@collTimeTracking.remove
		puts "MongoDB Collection has been Cleared"
	end

	def remove_mongo_records(downloadID)
		@collTimeTracking.remove( { "admin_info.download_id"=> downloadID } )
	end

	def putIntoMongoCollTimeTrackingCommits(mongoPayload)
		@collTimeTracking.insert(mongoPayload)
	end

	def aggregate(input1)
		@collTimeTracking.aggregate(input1)
	end


end