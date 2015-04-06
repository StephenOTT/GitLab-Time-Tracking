# GitLab-Time-Tracking

[![Join the chat at https://gitter.im/StephenOTT/GitLab-Time-Tracking](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/StephenOTT/GitLab-Time-Tracking?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Time Tracking application for GitLab Issue Queues built on Ruby Sinatra and MongoDB.


##System Requirements
1. GitLab Version 7.9+
2. Ruby 2.x+
3. MongoDB 2.x+



##Installation

1. Register/Create an Application at https://gitlab.com/oauth/applications/new.  Set your fields to the following:

	1.1. Name: `GitLab-Time-Tracking` or whatever you want to call your application.
	
	1.2. Redirect URI: `http://localhost:9292/auth/gitlab/callback`

2. Install MongoDB (typically: `brew update`, followed by: `brew install mongodb`)

3. `cd` into the repository's `app` folder and run the following commands in the `app` folder:

	3.1. Run `mongod` in terminal

	3.2. Open a second terminal window in the `app` folder and run: `bundle install`
	
	3.3. Get the Client ID/Application ID and Client Secret/Application Secret from the settings of your created/registered GitLab Application in Step 1.
	
	3.4. In the second terminal window copy the below, add your Client ID and Client Secret, and run: `GITLAB_ENDPOINT="https://gitlab.com" GITLAB_CLIENT_ID="APPLICATION_ID" GITLAB_CLIENT_SECRET="APPLICATION_SECRET" MONGODB_HOST="localhost" MONGODB_PORT="27017" MONGODB_DB="GitLab" MONGODB_COLL="Issues_Time_Tracking" bundle exec rackup`
	

4. Go to `http://localhost:9292`


## Current Features:

1. Download Issue Time Tracking Data from Multiple GitLab Projects.
2. Clear MongoDB Database Collection.
3. Download XLSX Version of Time Tracking Data.
4. Download of Milestone Budget data for Milestones that are attached to Issues.
5. For Each downloaded dataset you can view the time tracking logs related to the specific download.
6. Download specific XLSX file for each downloaded data set/snapshots.


## Notes

1. You can only connect to one GitLab Endpoint per application instance.  If you wish to connect to multiple GitLab instances, then you must run multiple instances of the GitLab Time Tracking Application
2. Only Issues that have notes/comments with Time Tracking records are downloaded into MongoDB.
3. The same MongoDB database can be used by multiple instances of GitLab Time Tracking.
4. Design Philosophy: Ensure maximum ease of use per record for a business user.  Each record contains all information needed to exist on its own without any other records.

## Current Limitations

1. The current code being used for converting human readable durations such as "1d"(1 day) or "1w"(1 week), calculates as "24 hours per day".  A future update will allow you to control how you calculate a "Day".  The current **workaround** for this issue/limitation is to always log your time and budgets using Hours or a small time duration (example: 15h, 15m, 15s).

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


### Logging Budgets for a Milestone

Logging a budget for a milestone should be done at the beginning of the milestone description.  The typical milestone description information comes after the budget information.  See example 2 below for a typical usage pattern.

#### Examples

1. `:dart: 5d` # => :dart: 5d

2. `:dart: 5d | We cannot go over this time at all!` # => :dart: 5d | We cannot go over this time at all! 

#### Sample
![screen shot 2013-12-15 at 8 42 04 pm](https://f.cloud.github.com/assets/1994838/1751601/bb73ed86-65f3-11e3-9abb-4c47eabbc608.png)
![screen shot 2013-12-15 at 8 41 55 pm](https://f.cloud.github.com/assets/1994838/1751602/bb757d9a-65f3-11e3-9ac5-86dba26bc037.png)


### Tracking Non-Billable Time and Budgets

The ability to indicate where a Time Log and Budget is considered Non-Billable has been provided.  This is typically used when staff are doing work that will not be billed to the client, but you want to track their time and indicate how much non-billable/free time has been allocated.  The assumption is that all time logs and budgets are billable unless indicated to be Non-Billable.

You may indicate when a time log or budget is non-billable time in any Issue Time Log, Issue Budget, Milestone Budget, Code Commit Message, and Code Commit Comment.

To indicate if time or budgets are non-billable, you add the `:free:` :free: emoji right after your chosen `clock` emoji (like `:clock1:` :clock1:) or for budget you would place the `:free:` :free: emoji right after the `:dart:` :dart: emoji.

#### Non-Billable Time and Budget Tracking Indicator Usage Example


##### Logging Non-Billable Time for an Issue

###### Examples

1. `:clock1: :free: 2h` # => :clock1: :free: 2h

##### Logging Non-Billable Budgets for a Milestone

###### Examples

1. `:dart: :free: 5d` # => :dart: :free: 5d


