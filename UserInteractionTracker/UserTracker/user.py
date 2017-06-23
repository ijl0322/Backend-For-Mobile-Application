from google.appengine.ext import ndb
import logging

class UserHash(ndb.Model):
	user_list = ndb.StringProperty(repeated=True)
	new_user_count = ndb.IntegerProperty(default=0)

def add_user(id):
	user_hash_num = hash_user(id)
	user_hash_object = UserHash.get_by_id(user_hash_num)
	if user_hash_object is None:
		user_hash_object = UserHash(id=user_hash_num)
	current_user_list = user_hash_object.user_list
	if id not in current_user_list:
		current_user_list.append(id)
		user_hash_object.user_list = current_user_list
		user_hash_object.new_user_count += 1
		user_hash_object.put()
		
def hash_user(id):
	total = 0
	for char in id:
		total += ord(char)
	print "The hash is %d" %(total%20) 
	return total%20

def total_daily_new_user():
	total = 0
	for counter in UserHash.query():
		total += counter.new_user_count
	return total

def reset():
	for counter in UserHash.query():
		counter.new_user_count = 0
		counter.put()