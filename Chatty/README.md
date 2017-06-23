# Chatty

A group chat app that uses firebase as its backend solution. Allows the user to create a group and invite other users to the group using deep link. This app uses Google account for user authentications.

## Structure of Firebase Database

- Groups
	- Auto ID for each group
		- name
		- online
		- userList
- Users
	- UID from google authentication
		- name
		- avatar
		- groupList
- Messages
	- Group ID 
		- Auto ID for each message
			- message
			- imageUrl
			- user (the auto id of the user who posted this message)

### Groups
When a new group is created, an auto ID is assigned to the group, and the group's name is added to that auto id. 
The user who created the group will be the first member of the group, so his/her user id will be added to userList under that group.
The group autoID is later used in invitations to identify which group the new user is invited to. 
And when a user is using the app to view messages of one particular group, his/her user id is added to online.


### User
When a user is authenticated, the user's unique id is added to Users, along with the user's name and avatar from google's authentication. 
Under each user, a groupList is maintained, and keeps track of the group id of all the groups a user belongs to. 
Even though the groups a user belongs to can be obtained by going through the userList inf Groups, it seems very inefficient to go through all the groups just to find this information.


### Messages
In messages, a group id identifies which group the message belongs to. 
Under each group id is a list of messages.
Each message will have a user id, and either a message (which is plain text), or a imageUrl (which is the url of a image in Firebase Storage).

## Issues 

Chatty was designed to be use on all devices, but it currently has a small issue in the Messages View Controller for view animation. 
The vc usese NotificationCenter to observe: .UIKeyboardWillShow, and dynamically get the height of the keyboard. However, this does not update the keyboard's height before the first time the keyboard shows, so I had to hardcode a initial keyboard height. The height is for iphone 7, and will cause weird view animations if the device is not iphone 7. I'm currently working on resolving this issue, but if the view is still acting weird, please grade this homework using iphone 7 simulator. (Also, this animation will only work with the simulator keyboard, using the hardware keybaord will result in a black area showing up where the keyboard should be)


In every group, inside the MessagesVC, there is a label showing the group name and how many people are currently online. In viewDidLoad, the user is added to the online list in firebase database, and is removed in viewWillDisappear. Under normal circumstances, this functions correcly. However, when running on a simulator, if the user is in the MessagesVC and they stop running the program, they are never removed from the online list, and the online list will show incorrect number of users. Currently this issue is left as is because I don't think this will occur when a user is using this app on an actually device.


## Attributions

http://stackoverflow.com/questions/36210424/retrieve-randomly-generated-child-id-from-firebase

http://stackoverflow.com/questions/24334653/colorwithalphacomponent-example-in-swift

http://stackoverflow.com/questions/1126726/how-to-make-a-uitextfield-move-up-when-keyboard-is-present

http://stackoverflow.com/questions/11989306/get-the-frame-of-the-keyboard-dynamically

http://stackoverflow.com/questions/2267993/uitableview-how-to-disable-selection-for-some-rows-but-not-others

http://stackoverflow.com/questions/4414221/uiimage-in-a-circle

