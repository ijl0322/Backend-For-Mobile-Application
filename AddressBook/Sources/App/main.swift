import Vapor
import VaporPostgreSQL

let drop = Droplet()

do {
  try drop.addProvider(VaporPostgreSQL.Provider.self)
  drop.preparations = [Addr.self]
} catch {
  assertionFailure("Error adding provider: \(error)")
}

drop.get("version") { req in
  if let db = drop.database?.driver as? PostgreSQLDriver {
    let version = try db.raw("SELECT version()")
    return try JSON(node: version)
  } else {
    return "No database connection"
  }
}

drop.get("hello") { req in
    return "Hello!"
}

drop.get("model") { request in
    let address = Addr(firstName: "Isabel", lastName: "Lee", phone: "6261231234", address: "test")
    return try address.makeJSON()
}

// Add new data to database

drop.post("new") { request in
    let name = request.data["firstname"]?.string
    guard let firstname = name else {
        return "Please specify a first name"
    }
    
    let lastname = request.data["lastname"]?.string ?? "No Data for Last Name"
    let phone = request.data["phone"]?.string ?? "No Phone Number Specified"
    let addr = request.data["address"]?.string ?? "No Address Specified"

    var address = Addr(firstName: firstname, lastName: lastname, phone: phone, address: addr)
    try address.save()
    return try JSON(node: Addr.all().makeNode())
}

// Search for data

drop.get("all") { request in
    return try JSON(node: Addr.all().makeNode())
}

drop.get("search", "firstName", String.self) { request, param in
    return try JSON(node: Addr.query().filter("firstname", param).all().makeNode())
}

drop.get("search", "lastName", String.self) { request, param in
    return try JSON(node: Addr.query().filter("lastname", param).all().makeNode())
}

drop.get("search", "phone", String.self) { request, param in
    return try JSON(node: Addr.query().filter("phone", param).all().makeNode())
}

drop.get("search", "address", String.self) { request, param in
    return try JSON(node: Addr.query().filter("address", param).all().makeNode())
}

drop.get("search", "id", Int.self) { request, param in
    return try JSON(node: Addr.query().filter("id", param).all().makeNode())
}

// Updating data

drop.patch("update", "id", Int.self) { request, param in
    var addressToUpdate = try Addr.query().filter("id", param).first()
    
    guard var newAddress = addressToUpdate else {
        return "Cannot find this entry"
    }
    
    let firstname = request.data["firstname"]?.string
    let lastname = request.data["lastname"]?.string
    let phone = request.data["phone"]?.string
    let addr = request.data["address"]?.string
    
    if let firstname = firstname {
        newAddress.firstname = firstname
    }
    
    if let lastname = lastname {
        newAddress.lastname = lastname
    }
    
    if let phone = phone {
        newAddress.phone = phone
    }
    
    if let addr = addr {
        newAddress.address = addr
    }
    
    try newAddress.save()
    return newAddress
}

// Deleting data using id

drop.delete("delete", "id", Int.self) { request, param in
    var addressToDelete = try Addr.query().filter("id", param).first()
    
    guard var address = addressToDelete else {
        return "Cannot find this entry"
    }
    
    try address.delete()
    return try JSON(node: Addr.all().makeNode())
}

drop.run()



