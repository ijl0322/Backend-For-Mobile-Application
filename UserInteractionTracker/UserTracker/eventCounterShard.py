from google.appengine.ext import ndb
import random
import datetime


NUM_SHARDS = 20

class EventCounterShard(ndb.Model):
	session_count = ndb.IntegerProperty(default=0)
	session_length = ndb.FloatProperty(default=0)
	button1_count = ndb.IntegerProperty(default=0)
	button2_count = ndb.IntegerProperty(default=0)

#Go through all shards to get the count of all events and sessions
def get_count():
	num_session = 0
	total_session_length = 0.0
	avg_session_length = 0.0
	button1_total_tap = 0
	button2_total_tap = 0
	for counter in EventCounterShard.query():
		num_session += counter.session_count
		total_session_length += counter.session_length
		button1_total_tap += counter.button1_count
		button2_total_tap += counter.button2_count
	if num_session != 0 and total_session_length != 0:
		avg_session_length = total_session_length/num_session
	return {"num_session": num_session, "avg_session_length": avg_session_length,
	        "button1_count": button1_total_tap, "button2_count": button2_total_tap}

#Add data to one random shard
def add_data(session_length, button1_count, button2_count):
	shard_index = str(random.randint(0, NUM_SHARDS - 1))
	counter = EventCounterShard.get_by_id(shard_index)
	if counter is None:
		counter = EventCounterShard(id=shard_index)
	counter.session_count += 1
	counter.session_length += session_length
	counter.button1_count += button1_count
	counter.button2_count += button2_count
 	counter.put()

#Reset all values in every shard to 0
def reset():
	for counter in EventCounterShard.query():
		counter.num_session = 0 
		counter.session_length = 0
		counter.button1_count = 0
		counter.session_count = 0
		counter.button2_count = 0
		counter.put()



