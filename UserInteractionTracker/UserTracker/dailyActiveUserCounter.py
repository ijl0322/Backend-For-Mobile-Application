from google.appengine.ext import ndb
import logging

class DailyActiveUserCounter(ndb.Model):
	user_list = ndb.StringProperty(repeated=True)

def add_user(id):
	user_hash_num = hash_user(id)
	user_hash_object = DailyActiveUserCounter.get_by_id(user_hash_num)
	if user_hash_object is None:
		user_hash_object = DailyActiveUserCounter(id=user_hash_num)
	current_user_list = user_hash_object.user_list
	if id not in current_user_list:
		current_user_list.append(id)
		user_hash_object.user_list = current_user_list
		user_hash_object.put()

#Get a username's hash number		
def hash_user(id):
	total = 0
	for char in id:
		total += ord(char)
	print "The hash is %d" %(total%20) 
	return total%20

#Returns a list of all users who have used this app
def get_all_user():
	user_list = []
	for counter in DailyActiveUserCounter.query():
		user_list += counter.user_list
	return user_list

#Reset all shards to an empty list
def reset():
	for counter in DailyActiveUserCounter.query():
		counter.user_list = []
		counter.put()