require 'awesome_print'
require 'gitlab'
require 'omniauth'
require 'omniauth-gitlab'
require 'sinatra'
require 'rack-flash'
require_relative 'gitlab_downloader'
require_relative 'csv_exporter'
require_relative 'mongo_connection'

set :logging, :true
set :show_exceptions, true 

use Rack::Session::Pool
set :session_secret, 'Password!' # TODO Change this to a ENV

# TODO add the ability to set the endpoint api after the app has been initilized
use OmniAuth::Builder do
	provider :gitlab, ENV["GITLAB_CLIENT_ID"], ENV["GITLAB_CLIENT_SECRET"]
end

use Rack::Flash, :sweep => true

# Testing code - Outputs the Client ID and Secrect to the Console to ensure that the ENV was taken
# ap ENV["GITLAB_CLIENT_ID"]
# ap ENV["GITLAB_CLIENT_SECRET"]
# End of Testing Code

helpers do
	def current_user
		session["current_user"]
	end

	def gitlab_instance
		if @gl == nil
			endpoint = gitlab_endpoint
			@gl = GitLab_Downloader.new(endpoint, current_user["private_token"])
		else
			@gl
		end
	end

	def mongoConnection
		if @mongoConnection == nil
			@mongoConnection = Mongo_Connection.new(ENV["MONGODB_HOST"], ENV["MONGODB_PORT"].to_i, ENV["MONGODB_DB"], ENV["MONGODB_COLL"])  
		else
			@mongoConnection
		end
	end

	def gitlab_endpoint
		ENV["GITLAB_ENDPOINT"]
	end

	def user_projects
		
		gitlab_instance.user_projects
	end
end

get '/' do
	if current_user == nil
		flash[:warning] = ["You must log in to download data"]
	end
	
	erb :index
end

get '/download' do

	'<a href="/gl-download/153287">Download data from GitLab into MongoDB (project id: 153287)</a>
	<p>url pattern is: localhost:4567/gl-download/PROJECT_ID
	<br><br>
	<a href="/download-csv">Download data from MongoDB to .CSV</a>
	<br>
	<a href="/clear-mongo">Clear MongoDB Database</a>'

end

get '/clear-mongo' do

	mongoConnection.clear_mongo_collections
	flash[:success] = ["Database has been cleared"]
	redirect '/'

end



get '/download-csv' do
	dataExportConnection = CSVExporter.new(mongoConnection)
	dataExport = dataExportConnection.get_all_issues_time

	content_type 'application/csv'
	attachment "GitLab-Time-Tracking-Data.csv"

	csv = dataExportConnection.generateCSV(dataExport)
end


post '/gl-download' do

	if current_user == nil
		flash[:warning] = ["You must log in to download data"]
	else
		post = params[:post]
		# projectID = post[:projectid]
		repoProjectID = post[:repo]
		# endpoint = gitlab_endpoint

		# g = GitLab_Downloader.new(endpoint, current_user["private_token"])

		issuesWithComments = gitlab_instance.downloadIssuesAndComments(repoProjectID)
		if issuesWithComments.length > 0
			mongoConnection.putIntoMongoCollTimeTrackingCommits(issuesWithComments)
			flash[:success] = ["Time Tracking Data has been Downloaded from #{gitlab_endpoint}"]
		else
			flash[:danger] = ["No Time Tracking Data was found"]
		end

	end
	redirect '/'

end

get '/auth/:name/callback' do
	auth = request.env["omniauth.auth"]
	username = auth["info"]["username"]
	private_token = auth["extra"]["raw_info"]["private_token"]
	userID = auth["uid"]
	session["current_user"] = {"username" => username, "private_token" => private_token}


	# session[:user_id] = auth["uid"]
	redirect '/'
end

# any of the following routes should work to sign the user in: 
#   /sign_up, /signup, /sign_in, /signin, /log_in, /login
["/sign_in/?", "/signin/?", "/log_in/?", "/login/?", "/sign_up/?", "/signup/?"].each do |path|
	get path do
		redirect '/auth/gitlab'
	end
end

# either /log_out, /logout, /sign_out, or /signout will end the session and log the user out
["/sign_out/?", "/signout/?", "/log_out/?", "/logout/?"].each do |path|
	get path do
		# session[:user_id] = nil
		# @private_token = nil
		redirect '/'
	end
end