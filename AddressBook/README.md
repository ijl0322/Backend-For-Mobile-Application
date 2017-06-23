# Address Book - Using Vapor and Heroku

All data are returned in JSON format. In this address book, every field other than the first name is optional. If no first name is provided, the post request will be rejected by the database. However, it will accept it if the user enters an empty string for the first name. The update/delete method requires the user to use the id number of an entity to identify it. The id number can be obtained by using the search get requests specified below. 

## Get

### Getting all address book data from the database

curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:8080/all

curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://shielded-lake-16378.herokuapp.com/all

### Searching for an entry that matches a first name

- Usage
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:8080/search/firstName/[firstName]

- Examples
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:8080/search/firstName/Isabel
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://shielded-lake-16378.herokuapp.com/search/firstName/Isabel

#### Searching for an entry that matches a last name

- Usage: 
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:8080/search/lastName/[lastName]

- Examples
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:8080/search/lastName/Lee
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://shielded-lake-16378.herokuapp.com/search/lastName/Lee

#### Searching for an entry that matches a phone number

- Usage: 
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:8080/search/phone/[phoneNumber]

- Examples

	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:8080/search/phone/1231231234
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://shielded-lake-16378.herokuapp.com/search/phone/1231231234

#### Searching for an entry that matches an address (replace test with any address)

- Usage:
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:8080/search/address/[address]

- Examples
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:8080/search/address/test
	- curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://shielded-lake-16378.herokuapp.com/search/address/test

#### Adding new data 
- Examples
	- curl --data "firstname=Isabel&lastname=Lee&phone=1231231234&address=testtest" http://localhost:8080/new 
	- curl --data "firstname=Isabel&lastname=Lee&phone=1231231234&address=test" https://shielded-lake-16378.herokuapp.com/new

#### Update existing data

- Usage:
	- curl --data "firstname=Isabel&lastname=Lee&phone=1231231234&address=testtest" --request PATCH http://localhost:8080/update/id/[id_number]
- Examples
	- curl --data "firstname=Isabel&lastname=Lee&phone=1231231234&address=testtest" --request PATCH http://localhost:8080/update/id/2
	- curl --data "firstname=Isabel&lastname=Lee&phone=1231231234&address=testtest" --request PATCH https://shielded-lake-16378.herokuapp.com/update/id/2

#### Deleting existing data

- Usage: 
	- curl --request DELETE http://localhost:8080/delete/id/[id_number]
- Examples:
	- curl --request DELETE http://localhost:8080/delete/id/9
	- curl --request DELETE https://shielded-lake-16378.herokuapp.com/delete/id/1

