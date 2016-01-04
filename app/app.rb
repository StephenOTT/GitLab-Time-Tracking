require 'awesome_print'
require 'gitlab'
require 'omniauth'
require 'omniauth-gitlab'
require 'sinatra'
require 'rack-flash'
require_relative 'gitlab_downloader'
require_relative 'xlsx_exporter'
require_relative 'mongo_connection'
require_relative 'aggregations/admin_queries'
require_relative 'aggregations/issue_stat_queries'

set :logging, :true
set :show_exceptions, true 

use Rack::Session::Pool
set :session_secret, 'Password!' # TODO Change this to a ENV

# TODO add the ability to set the endpoint api after the app has been initilized
use OmniAuth::Builder do
	provider :gitlab, ENV["GITLAB_CLIENT_ID"], ENV["GITLAB_CLIENT_SECRET"],
			client_options: {
				site: ENV["GITLAB_ENDPOINT"]
			}
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
			@gl = GitLab_Downloader.new(gitlab_endpoint, current_user["private_token"])
		else
			@gl
		end
	end

	def admin_queries
		if @aq == nil
			@aq = Admin_Queries.new(mongoConnection)
		else
			@aq
		end
	end

	def get_issues_for_milestone(downloadID, milestoneNumber)
		issue_stat_queries.get_issues_for_milestone(downloadID,milestoneNumber)
	end

	def get_milestone_sums(downloadID, milestoneNumber)
		issue_stat_queries.get_milestone_sums(downloadID, milestoneNumber)
	end

        def get_milestone_points(downloadID, milestoneNumber)
                issue_stat_queries.get_milestone_points(downloadID, milestoneNumber)
        end

	def issue_stat_queries
		if @isq == nil
			@isq = Issue_Stat_Queries.new(mongoConnection)
		else
			@isq
		end
	end

	def mongoConnection
		if @mongoConnection == nil
			@mongoConnection = Mongo_Connection.new(ENV["MONGODB_HOST"], ENV["MONGODB_PORT"].to_i, ENV["MONGODB_DB"], ENV["MONGODB_COLL"])  
		else
			@mongoConnection
		end
	end

	def gitlab_endpoint(style = "full")
		if style == "full"
			ENV["GITLAB_ENDPOINT"] + (ENV['ENDPOINT_API_ADDRESS'] || "/api/v3")
		elsif style == "short"
			ENV["GITLAB_ENDPOINT"]
		end	
	end
end

get '/' do
	if current_user == nil
		flash[:warning] = ["You must <a href='/login'>Login </a> to your GitLab Instance to continue"]
	else
		@projectList = gitlab_instance.user_projects
		@adminQueries = admin_queries.get_downloads
	end
	
	erb :index
end

get '/clear-mongo/:downloadID' do
	downloadID = params[:downloadID]

	mongoConnection.remove_mongo_records(downloadID)

	# mongoConnection.clear_mongo_collections
	flash[:success] = ["Snapshot has been cleared (#{downloadID})"]
	redirect '/'

end

get '/download-xlsx/:downloadID' do
	downloadID = params[:downloadID]

	if current_user == nil
		redirect '/'
	elsif current_user != nil and downloadID != nil
		
		dataExportConnection = XLSXExporter.new(mongoConnection)
		dataExportIssues = dataExportConnection.get_all_issues_time(downloadID)
		dataExportMilestones = dataExportConnection.get_all_milestone_budgets(downloadID)
                dataExportStoryPoints = dataExportConnection.get_all_story_points(downloadID)

                if dataExportIssues.empty? == false or dataExportMilestones.empty? == false or dataExportStoryPoints.empty? == false

			content_type 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
			attachment 'time-tracking.xlsx'

			file = dataExportConnection.generateXLSX(dataExportIssues, dataExportMilestones, dataExportStoryPoints)
		else
			flash[:danger] = ["Unable to generate a xlsx: No time tracking data has been downloaded"]
			redirect '/'
		end
	else
		flash[:danger] = ["Error Location 001: Something went wrong"]
		redirect '/'
	end
	
end


post '/gl-download' do
	post = params[:post]

	if current_user == nil
		flash[:warning] = ["You must log in to download data"]
	
	elsif current_user != nil and post != nil

		repoProjectID = post[:repo]
		issuesWithComments = gitlab_instance.downloadIssuesAndComments(repoProjectID)
		
		if issuesWithComments.length > 0
			mongoConnection.putIntoMongoCollTimeTrackingCommits(issuesWithComments)
			flash[:success] = ["Time Tracking Data has been Downloaded from #{gitlab_endpoint('short')}"]
		else
			flash[:danger] = ["Unable to download Time Tracking data from #{gitlab_endpoint('short')}: No Time Tracking Data was found"]
		end
	
	elsif post == nil 
		flash[:warning] = ["You must select a Project to download, ensure you are the member or owner of a Project at #{gitlab_endpoint('short')}"]

	end
	redirect '/'

end

get '/analyze/:downloadID' do
	downloadID = params[:downloadID]

	if current_user == nil
		flash[:warning] = ["You must log in to download data"]
		redirect '/'
	elsif current_user != nil and downloadID != nil

		@milestones = issue_stat_queries.get_milestones(downloadID)
		@snapshot_info = issue_stat_queries.get_project_snapshot_info(downloadID)

		erb :analyze
	else
		flash[:danger] = ["Something went wrong: error location A1"]
	end

end

get '/auth/:name/callback' do
	auth = request.env["omniauth.auth"]
	
	username = auth["info"]["username"]
	private_token = auth["extra"]["raw_info"]["private_token"]
	userID = auth["uid"]

	session["current_user"] = {"username" => username, "user_id" => userID, "private_token" => private_token}

	redirect '/'
end

# any of the following routes should work to sign the user in: 
#   /sign_up, /signup, /sign_in, /signin, /log_in, /login
# TODO make only a single signin url
["/sign_in/?", "/signin/?", "/log_in/?", "/login/?", "/sign_up/?", "/signup/?"].each do |path|
	get path do
		redirect '/auth/gitlab'
	end
end

# either /log_out, /logout, /sign_out, or /signout will end the session and log the user out
# TODO make only a single signout url
["/sign_out/?", "/signout/?", "/log_out/?", "/logout/?"].each do |path|
	get path do
		session["current_user"] = nil
		flash[:success] = ["You were Logged out"]
		redirect '/'
	end
end
