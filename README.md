# GitLab-Time-Tracking

Time Tracking application for GitLab Issue Queues built on Ruby Sinatra and MongoDB.


##Installation

1. Register/Create an Application at https://gitlab.com/oauth/applications/new.  Set your fields to the following:

	1.1. Name: `GitLab-Time-Tracking` or whatever you want to call your application.
	
	1.2. Redirect URI: `http://localhost:9292/auth/gitlab/callback`

2. Install MongoDB (typically: `brew update`, followed by: `brew install mongodb`)

3. `cd` into the repository's `app` folder and run the following commands in the `app` folder:

	3.1. Run `mongod` in terminal

	3.2. Open a second terminal window in the `app` folder and run: `bundle install`
	
	3.3. Get the Client ID/Application ID and Client Secret/Application Secret from the settings of your created/registered GitLab Application in Step 1.
	
	3.4. In the second terminal window copy the below, add your Client ID and Client Secret, and run: `GITLAB_ENDPOINT="https://gitlab.com/api/v3" GITLAB_CLIENT_ID="APPLICATION_ID" GITLAB_CLIENT_SECRET="APPLICATION_SECRET" MONGODB_HOST="localhost" MONGODB_PORT="27017" MONGODB_DB="GitLab" MONGODB_COLL="Issues_Time_Tracking" bundle exec rackup`
	

4. Go to `http://localhost:9292`


## Current Features:

1. Download All Time Tracking Data from a Single GitLab Project.
2. Clear MongoDB Database Collection.
3. Download CSV Version of Time Tracking Data.


## Notes

1. You can only connect to one GitLab Endpoint per application instance.  If you wish to connect to multiple GitLab instances, then you must run multiple instances of the GitLab Time Tracking Application
2. Only Issues that have notes/comments with Time Tracking records are downloaded into MongoDB.
3. The same MongoDB database can be used by multiple instances of GitLab Time Tracking.



## Time Tracking Usage Patterns

### Logging Time for an Issue

Logging time for a specific issue should be done in its own comment.  The comment should not include any data other than the time tracking information.


#### Examples

1. `:clock1: 2h` # => :clock1: 2h

2. `:clock1: 2h | 3pm` # => :clock1: 2h | 3pm

3. `:clock1: 2h | 3:20pm` # => :clock1: 2h | 3:20pm

4. `:clock1: 2h | Feb 26, 2014` # => :clock1: 2h | Feb 26, 2014

5. `:clock1: 2h | Feb 26, 2014 3pm` # => :clock1: 2h | Feb 26, 2014 3pm

6. `:clock1: 2h | Feb 26, 2014 3:20pm` # => :clock1: 2h | Feb 26, 2014 3:20pm

7. `:clock1: 2h | Installed security patch and restarted the server.` # => :clock1: 2h | Installed security patch and restarted the server.

8. `:clock1: 2h | 3pm | Installed security patch and restarted the server.` # => :clock1: 2h | 3pm | Installed security patch and restarted the server.

9. `:clock1: 2h | 3:20pm | Installed security patch and restarted the server.` # => :clock1: 2h | 3:20pm | Installed security patch and restarted the server.

10. `:clock1: 2h | Feb 26, 2014 | Installed security patch and restarted the server.` # => :clock1: 2h | Feb 26, 2014 | Installed security patch and restarted the server.

11. `:clock1: 2h | Feb 26, 2014 3pm | Installed security patch and restarted the server.` # => :clock1: 2h | Feb 26, 2014 3pm | Installed security patch and restarted the server.

12. `:clock1: 2h | Feb 26, 2014 3:20pm | Installed security patch and restarted the server.` # => :clock1: 2h | Feb 26, 2014 3:20pm | Installed security patch and restarted the server.


- Dates and times can be provided in various formats, but the above formats are recommended for plain text readability.

- Any GitHub.com supported `clock` Emoji is supported:
":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", ":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", ":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", ":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", ":clock4:", ":clock530:", ":clock7:", ":clock830:"

#### Sample
![screen shot 2013-12-15 at 8 41 35 pm](https://f.cloud.github.com/assets/1994838/1751599/b03deba6-65f3-11e3-9a4a-6e30ca750fd6.png)

### Non-Billable Time Indicator Usage Example

#### Logging Non-Billable Time for an Issue

##### Examples

1. `:clock1: :free: 2h` # => :clock1: :free: 2h

