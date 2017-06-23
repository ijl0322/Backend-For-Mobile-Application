
from google.appengine.api import mail
from google.appengine.api import taskqueue
import webapp2
import datetime
import urllib
import json
import logging
import user
import eventCounterShard
import dailyActiveUserCounter
import dailyActivityRecords
import touchTracker


class MainPage(webapp2.RequestHandler):
	
	def get(self):
		self.response.headers['Content-Type'] = 'text/plain'
		self.response.write('Hello, Developer!')

	def post(self):
		json_string = self.request.body
		json_object = json.loads(json_string)
		logging.info("JSON: "+json_string)
		update_database(json_object)
		self.response.out.write(json_string)

def update_database(json):
	button1_count = json["events"]["button1"]
	button2_count = json["events"]["button2"]
	session_length = json["sessionTime"]
	user_id = json["user"]
	touches = json["touches"]
	eventCounterShard.add_data(session_length, button1_count, button2_count)
	user.add_user(user_id)
	dailyActiveUserCounter.add_user(user_id)
	touchTracker.add_data(touches)
	print touchTracker.get_all_touches()
	logging.info("The database has been updated")

class EmailTaskHandler(webapp2.RequestHandler):
	"""Handler for task queue emails"""

	def get(self):
		update_summary(self)
		f = urllib.urlopen(touchTracker.touchChartURl())
		message = self.request.get('message', default_value='default')
		logging.info('\n\n ============= Sending an email ==============')
		mail.send_mail(sender="dailySummary@usertracker-164618.appspotmail.com",
		to="ijlee@uchicago.edu",
		subject="Your daily summary email is here!",
		body=dailyActivityRecords.format_summary().replace("<br>", "\n") + "Touch Heat Map: " + touchTracker.touchChartURl(), attachments=["touchHeatMap.png", f.read()])
		self.response.out.write('<br>Your daily summary email has been sent!')
		touchTracker.reset()
		self.response.out.write("<br>Touch information has been cleared")


class DailySummaryHandler(webapp2.RequestHandler):

	def get(self):
		update_summary(self)

def update_summary(self):
	summary = eventCounterShard.get_count()
	user_list = dailyActiveUserCounter.get_all_user()
	daily_new_user_num = user.total_daily_new_user()
	dailyActivityRecords.update(summary["num_session"], summary["avg_session_length"], 
								summary["button1_count"], summary["button2_count"], user_list, daily_new_user_num)
	self.response.out.write(dailyActivityRecords.format_summary())
	eventCounterShard.reset()
	dailyActiveUserCounter.reset()
	user.reset()

class TouchChartHandler(webapp2.RequestHandler):
	def get(self, action):
		if action == "show":
			self.response.out.write(touchTracker.showTouchChart())
		elif action == "clear":
			touchTracker.reset()
			self.response.out.write("Touch information has been cleared")


## Specifies which path should be handled by which class
app = webapp2.WSGIApplication([
	('/', MainPage),('/json/', MainPage),
	('/summaryEmail/', EmailTaskHandler),
	('/dailySummary/', DailySummaryHandler),
	webapp2.Route('/touchChart/<action>/', TouchChartHandler)
], debug=True)
