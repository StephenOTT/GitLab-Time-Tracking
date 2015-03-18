# GitLab-Time-Tracking
Lightweight Time Tracking application for GitLab Issue Queues


##Installation

1. Register/Create an Application at https://gitlab.com/oauth/applications/new.  Set your fields to the following:

	1.1. Name: `GitLab-Time-Tracking` or whatever you want to call your application.
	
	1.2. Redirect URI: `http://localhost:4567/auth/gitlab/callback`

2. Install MongoDB (typically: `brew update`, followed by: `brew install mongodb`)

3. `cd` into the repository's `app` folder and run the following commands in the `app` folder:

	3.1. Run `mongod` in terminal

	3.2. Open a second terminal window in the `app` folder and run: `bundle install`
	
	3.3. In the second terminal window, run: `GITLAB_CLIENT_ID="APPLICATION ID" GITLAB_CLIENT_SECRET="APPLICATION SECRET" MONGODB_HOST="HOST URL" MONGODB_PORT="PORT NUMBER" MONGODB_DB="DATABASE NAME" MONGODB_COLL="COLLECTION NAME" bundle exec rackup`
	Get the Client ID/Application ID and Client Secret/Application Secret from the settings of your created/registered GitLab Application in Step 1.

4. Go to `http://localhost:4567`


## Current Features:

1. Download All Time Tracking Data from a Single GitLab Project.
2. Clear MongoDB Database Collection.
3. Download CSV Version of Time Tracking Data.