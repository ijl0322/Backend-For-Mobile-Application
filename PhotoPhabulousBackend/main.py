import cgi
import datetime
import urllib
import webapp2
import json
import logging
from uuid import uuid4

from google.appengine.api import memcache
from google.appengine.ext import ndb
from google.appengine.api import images

from models import *

################################################################################
"""The home page of the app"""
class HomeHandler(webapp2.RequestHandler):

    """Show the webform when the user is on the home page"""
    def get(self):
        self.response.out.write('<html><body>')

        # Print out some stats on caching
        stats = memcache.get_stats()
        self.response.write('<b>Cache Hits:{}</b><br>'.format(stats['hits']))
        self.response.write('<b>Cache Misses:{}</b><br><br>'.format(
                            stats['misses']))

        user = self.request.get('user')
        ancestor_key = ndb.Key("User", user or "*notitle*")
        # Query the datastore
        #photos = Photo.query_user(ancestor_key).fetch(100)


        self.response.out.write("""
        <form action="/post/default/" enctype="multipart/form-data" method="post">
        <div><textarea name="caption" rows="3" cols="60"></textarea></div>
        <div><label>Photo:</label></div>
        <div><input type="file" name="image"/></div>
        <div>User <input value="default" name="user"></div>
        <div>ID token <input name="id_token"></div>
        <div><input type="submit" value="Post"></div>
        </form>
        <hr>
        </body>
        </html>""")


################################################################################
"""Handle activities associated with a given user"""
class UserHandler(webapp2.RequestHandler):

    """Print json or html version of the users photos"""

    def get(self, user, type):
        id_token = self.request.get('id_token')
        user_info = User.getPhotos(user, id_token)
        photo_keys = []
        photo_collection = []

        if user_info == None and type == "json":
            self.response.out.write(json.dumps({'results': []}))
            return
        elif user_info == None and type == "web":
            self.response.out.write("User/ID token pair not found")
            return
        else: 
            user_info = user_info.photos

        for key in user_info:
            photo_keys.append(key)
            photo_collection.append(ndb.Key(urlsafe=key).get())

        if type == "json":
            output = self.json_results(photo_collection, user)
        else:
            output = self.web_results(photo_collection, user)

        self.response.out.write(output)

    def json_results(self,photos,user):
        """Return formatted json from the datastore query"""
        json_array = []
        for photo in photos:
            dict = {}
            dict['image_url'] = "image/%s/" % photo.key.urlsafe()
            dict['caption'] = photo.caption
            dict['user'] = user
            dict['date'] = str(photo.date)
            json_array.append(dict)
        return json.dumps({'results' : json_array})

    def web_results(self,photos, user):
        """Return html formatted json from the datastore query"""
        html = ""
        for photo in photos:
            html += '<div><hr><div><img src="/image/%s/" width="200" border="1"/></div>' % photo.key.urlsafe()
            html += '<div><blockquote>Caption: %s<br>User: %s<br>Date:%s</blockquote></div></div>' % (cgi.escape(photo.caption),user,str(photo.date))
        return html

    @staticmethod
    def get_data(user):
        """Get data from the datastore only if we don't have it cached"""
        key = user + "_photos"
        data = memcache.get(key)
        if data is not None:
            logging.info("Found in cache")
            return data
        else:
            logging.info("Cache miss")
            ancestor_key = ndb.Key("User", user)
            data = Photo.query_user(ancestor_key).fetch(100)
            if not memcache.add(key, data, 3600):
                logging.info("Memcache failed")
        return data

################################################################################
"""Handle requests for an image ebased on its key"""
class ImageHandler(webapp2.RequestHandler):

    def get(self,key):
        """Write a response of an image (or 'no image') based on a key"""
        photo = ndb.Key(urlsafe=key).get()
        if photo.image:
            self.response.headers['Content-Type'] = 'image/png'
            self.response.out.write(photo.image)
        else:
            self.response.out.write('No image')


################################################################################
class PostHandler(webapp2.RequestHandler):
    def post(self,user):

        # If we are submitting from the web form, we will be passing
        # the user from the textbox.  If the post is coming from the
        # API then the username will be embedded in the URL
        if self.request.get('user'):
            user = self.request.get('user')

        # Be nice to our quotas
        thumbnail = images.resize(self.request.get('image'), 30,30)

        # Create and add a new Photo entity
        #
        # We set a parent key on the 'Photos' to ensure that they are all
        # in the same entity group. Queries across the single entity group
        # will be consistent. However, the write rate should be limited to
        # ~1/second.

        id_token = self.request.get('id_token')
        user_info = User.getUserByID(id_token)

        if user_info != None and user_info.username == user:
            photo = Photo(caption=self.request.get('caption'),
                image=thumbnail)
            photo.put()
            current_photo = user_info.photos
            current_photo.append(photo.key.urlsafe())
            user_info.photos = current_photo
            user_info.put()
            logging.info("========== photo added =========")
            self.response.out.write("Photo Added")
        
        else:
            self.response.out.write("User information is incorrect")

        # Clear the cache (the cached version is going to be outdated)
        key = user + "_photos"
        memcache.delete(key)

        # Redirect to print out JSON
        #self.redirect('/user/%s/json/' % user)

##################################################################################

class DeletePhotoHandler(webapp2.RequestHandler):
    def get(self, key):
        
        id_token = self.request.get('id_token')
        user = User.getUserByID(id_token)
        if user == None:
            self.response.out.write("Invalid ID token")
            return

        photos = user.photos

        if key in photos:
            self.response.out.write("Successfully Deleted")
            photo_key = ndb.Key(urlsafe=key)
            photo_key.delete()
            photos.remove(key)
            user.photos = photos
            user.put()
            logging.info("Photo deleted")
        else:
            self.response.out.write("Photo Does not belong to user")
        key = user.username + "_photos"
        memcache.delete(key)


class AddUserPostHandler(webapp2.RequestHandler):

    def post(self):
        user = self.request.get('username')
        users_name = self.request.get('name')
        user_email = self.request.get('email')
        user_password = self.request.get('password')

        if User.exists(user):
            self.response.out.write("pick a different username")
            return

        user_data = User(parent=ndb.Key("User", user),
                    name = users_name,
                    username = user,
                    password = user_password,
                    email = user_email, 
                    id_token = str(uuid4()))

        user_data.put()
        logging.info("========= Adding User with username : %s ==============" %user)
        self.response.out.write("UserAdded")

class AutheticationHandler(webapp2.RequestHandler):
    def post(self):
        username = self.request.get('username')
        password = self.request.get('password')
        result = User.authenticate(username, password)
        if result: 
            self.response.out.write(result[0].id_token)
        else:
            self.response.out.write("User/password pair does not exist")


################################################################################
class LoggingHandler(webapp2.RequestHandler):
    """Demonstrate the different levels of logging"""

    def get(self):
        logging.debug('This is a debug message')
        logging.info('This is an info message')
        logging.warning('This is a warning message')
        logging.error('This is an error message')
        logging.critical('This is a critical message')

        try:
            raise ValueError('This is a sample value error.')
        except ValueError:
            logging.exception('A example exception log.')

        self.response.out.write('Logging example.')


################################################################################

app = webapp2.WSGIApplication([
    ('/', HomeHandler),
    webapp2.Route('/logging/', handler=LoggingHandler),
    webapp2.Route('/image/<key>/', handler=ImageHandler),
    webapp2.Route('/post/<user>/', handler=PostHandler),
    webapp2.Route('/user/<user>/<type>/',handler=UserHandler),
    webapp2.Route('/adduser/', handler = AddUserPostHandler),
    webapp2.Route('/<key>/delete/', handler = DeletePhotoHandler),
    webapp2.Route('/authenticate/', handler = AutheticationHandler)
    ],
    debug=True)
