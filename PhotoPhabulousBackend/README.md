# Photo Phabulous Backend

A backend solution for the app PhotoPhabulous (https://github.com/ijl0322/iOS-Projects/tree/master/Photo%20Phabulous).

Allows an app to interact with the server by creating users, authenticating users, and saving/deleting a user's photo.

## Project Link: 
https://photophabulousbackend.appspot.com/

## Usage: 

### Adding a user: 
POST to : https://photophabulousbackend.appspot.com/adduser/
With Parameters: username=abc&name=isabel&email=abc@email.com&password=123

Note: This user has already been added, so using this link again will show a page "pick a different username"

#### User Properties: 

|Property                    |Type                                                      | 
|----------------------------|----------------------------------------------------------|
|name                        |(String)                                                  |
|email                       |(String)                                                  | 
|unique_id                   |(I used the key property instead)                         |
|photos                      |(A list of url safe strings generated from the photo key) |
|username                    |(String)                                                  |
|password                    |(String)                                                  |
|id_token                    |(Auto-generated url safe string)

When adding a user, specify username, name, email, password
id_token, unique_id, and photos does not have to be specified

### Authenticating a user

POST to: https://photophabulousbackend.appspot.com/authenticate/
With Parameters: username=abc&password=123

To authenticate a user, specify the username and password.

If authentication fails, a page will show "User/password pair does not exist", otherwise, it will return the user's id_token.
In the example above, it will return the user's id_token: 3ef7ac16-aabf-4342-84c6-99a2a2daa559

This token can be used to upload/get/delete photos.

### Adding a photo

Adding photos can be done through the home page: https://photophabulousbackend.appspot.com/
Both the username and id_token have to be correct for the image to upload successfully.
A page will show "Photo Added" when photo has been added successfully.

Or using curl:

curl -X POST -H "Content-Type: multipart/form-data" -F caption='curl' -F "image=@img1.jpg" https://photophabulousbackend.appspot.com/post/abc/?id_token=3ef7ac16-aabf-4342-84c6-99a2a2daa559

### Getting Json 
GET request example: https://photophabulousbackend.appspot.com/user/abc/json/?id_token=3ef7ac16-aabf-4342-84c6-99a2a2daa559

To get the Json file for a user, specify the user name and id_token

https://...appspot.com/user/[user]/json/?id_token=[id_token]

### Getting Web page
GET request example: https://photophabulousbackend.appspot.com/user/abc/web/?id_token=3ef7ac16-aabf-4342-84c6-99a2a2daa559

To view the Web file for a user, specify the user name and id_token

https://...appspot.com/user/[user]/web/?id_token=[id_token]

### Deleting a photo
To delete a photo, the url-safe photo key and user's id_token must both be provided. 

GET request example: https://photophabulousbackend.appspot.com/ahdzfnBob3RvcGhhYnVsb3VzYmFja2VuZHISCxIFUGhvdG8YgICAgPjChAoM/delete/?id_token=3ef7ac16-aabf-4342-84c6-99a2a2daa559

Note: this photo has been deleted while testing, so sending this request again will show "Photo Does not belong to user".

https://photophabulousbackend.appspot.com/[photo_key]/delete/?id_token=[id_token]


## Attribution: 

http://stackoverflow.com/questions/25185769/unprojectedpropertyerror-in-google-app-engine
http://stackoverflow.com/questions/11475473/python-how-do-i-find-out-if-an-appengine-gql-query-returns-anything
https://community.servicenow.com/community/develop/blog/2016/10/18/gql-glide-query-language-part-4-the-retriever
https://github.com/GoogleCloudPlatform/python-docs-samples/blob/master/appengine/standard/ndb/entities/snippets.py
