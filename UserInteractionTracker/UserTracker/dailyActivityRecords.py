from google.appengine.ext import ndb
import datetime
from pytz import timezone

now = datetime.datetime.now(timezone('UTC')).astimezone(timezone('US/Pacific'))

class DailyActivityRecords(ndb.Model):
	year = ndb.StringProperty()
	month = ndb.StringProperty()
	day = ndb.StringProperty()
	session_count = ndb.IntegerProperty(default=0)
	avg_session_length = ndb.FloatProperty(default=0)
	button1_count = ndb.IntegerProperty(default=0)
	button2_count = ndb.IntegerProperty(default=0)
	daily_active_user_list = ndb.StringProperty(repeated=True)
	daily_new_user = ndb.IntegerProperty(default=0)

#Update Database
def update(session_count, session_length, button1_count, button2_count, daily_active_user_list, daily_new_user):
	
	#now = datetime.datetime.now()
	year = now.year
	month = now.month
	day = now.day

	date_id = "%s-%s-%s" %(year, month, day)
	record = DailyActivityRecords.get_by_id(date_id)
	if record is None:
		record = DailyActivityRecords(id=date_id)
	record.year = str(year)
	record.month = str(month)
	record.day = str(day)
	total_length = record.avg_session_length * record.session_count + session_count * session_length
	record.session_count += session_count
	if record.session_count != 0:
		record.avg_session_length = total_length/record.session_count
	record.button1_count += button1_count
	record.button2_count += button2_count
	record.daily_new_user += daily_new_user
	current_record = record.daily_active_user_list
	if current_record != None:
		current_record += daily_active_user_list
		print current_record
		record.daily_active_user_list = list(set(current_record))
	else:
		record.daily_active_user_list = daily_active_user_list
	record.put()

#Go through daily records of this month to find monthly active users
def get_monthly_active_user_num():
	user_list = []
	for i in range(1, int(now.day) + 1):
		date_id = "%s-%s-%s" %(now.year, now.month, i)
		#print date_id
		record = DailyActivityRecords.get_by_id(date_id)
		if record != None:
			user_list += record.daily_active_user_list
	print user_list
	return len(set(user_list))

#Format summary to display on webpage and emails
def format_summary():
	year = now.year
	month = now.month
	day = now.day
	date_id = "%s-%s-%s" %(year, month, day)
	summary = DailyActivityRecords.get_by_id(date_id)
	daily_active_user_num = len(summary.daily_active_user_list)
	text_summary = "Hello Developer, We do not have records yet!"
	if summary != None:
		text_summary = "Hello Developer! <br> \
						Here is your summary of the day %s <br> \
						Total Number of Sessions Today: %s <br> \
						Average Session Length: %.2f seconds <br> \
						Button 1 tapped number: %s <br> \
						Button 2 tapped number: %s <br> \
						Daily Active User: %d  <br> \
						Daily New User: %s <br> \
						Monthly Active User: %s <br> " \
						%(date_id, summary.session_count, summary.avg_session_length, summary.button1_count, summary.button2_count, \
						daily_active_user_num, summary.daily_new_user, get_monthly_active_user_num())
	return text_summary
