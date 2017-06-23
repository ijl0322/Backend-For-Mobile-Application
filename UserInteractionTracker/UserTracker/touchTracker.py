from google.appengine.ext import ndb
import random

NUM_SHARDS = 20

class TouchTrackerShard(ndb.Model):
	touch_x = ndb.FloatProperty(repeated=True)
	touch_y = ndb.FloatProperty(repeated=True)

def get_all_touches():
	total_touch_x = []
	total_touch_y = []
	for counter in TouchTrackerShard.query():
		total_touch_x += counter.touch_x
		total_touch_y += counter.touch_y
	return total_touch_x, total_touch_y

def add_data(touches):
	new_touch_x = []
	new_touch_y = []

	for touch in touches:
		new_touch_x.append(touch["x"])
		new_touch_y.append(touch["y"])

	shard_index = str(random.randint(0, NUM_SHARDS - 1))
	counter = TouchTrackerShard.get_by_id(shard_index)
	if counter is None:
		counter = TouchTrackerShard(id=shard_index)
	current_x = counter.touch_x + new_touch_x
	current_y = counter.touch_y + new_touch_y
	counter.touch_x  = current_x
	counter.touch_y = current_y
 	counter.put()

def showTouchChart():
	touch_string = printTouches()
	html = '<html> \
  <head> \
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script> \
    <script type="text/javascript"> \
      google.charts.load("current", {"packages":["corechart"]}); \
      google.charts.setOnLoadCallback(drawChart); \
      function drawChart() { \
        var data = google.visualization.arrayToDataTable([ \
          ["X", "Y"] %s \
        ]); \
        var options = { \
          title: "Touch Heat Map - iPhone 7 Plus", \
          hAxis: {title: "X", minValue: 0, maxValue: 414}, \
          vAxis: {title: "Y", minValue: 0, maxValue: 736}, \
           legend: "none" \
        }; \
        var chart = new google.visualization.ScatterChart(document.getElementById("chart_div")); \
        chart.draw(data, options); \
      } \
    </script> \
  </head> \
  <body> \
    <div id="chart_div" style="width: 414px; height: 736px;"></div> \
  </body> \
</html> \ ' %touch_string

	if touch_string == "":
		html = "You have no touch data yet"
	return html

def printTouches():
	touch_string = ""
	all_touch_x, all_touch_y = get_all_touches()
	for i in range(len(all_touch_x)):
		touch_string += ","
		touch_string += "[ %s,      %s]" %(all_touch_x[i], all_touch_y[i])
	return touch_string

def touchChartURl():
  touch_string_x, touch_string_y = printTouchesForUrl()
  url = "https://chart.googleapis.com/chart?cht=s&chd=t:0%s|0%s&chxt=x,y&chs=300x500&chxr=0,0,500|1,0,800" %(touch_string_x, touch_string_y)
  print url
  return url

def printTouchesForUrl():
  all_touch_x, all_touch_y = get_all_touches()
  touch_string_x = ""
  touch_string_y = ""
  for i in range(len(all_touch_x)):
    touch_string_x += ","
    touch_string_y += ","
    touch_string_x += "%.2f" %(all_touch_x[i]/5)
    touch_string_y += "%.2f" %(all_touch_y[i]/8)
  return touch_string_x, touch_string_y


def reset():
	for counter in TouchTrackerShard.query():
		counter.touch_x = []
		counter.touch_y = []
		counter.put()
