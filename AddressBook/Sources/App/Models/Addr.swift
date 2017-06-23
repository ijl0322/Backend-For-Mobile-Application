//
//  Addr.swift
//  vapor-hello-world
//
//  Created by Isabel  Lee on 21/05/2017.
//
//

import Vapor
import Foundation

final class Addr: Model {
    
    var id: Node?
    var exists: Bool = false
    var firstname = ""
    var lastname = ""
    var phone = ""
    var address = ""
    
    init(firstName: String, lastName: String, phone: String, address: String) {
        self.id = nil
        self.firstname = firstName
        self.lastname = lastName
        self.phone = phone
        self.address = address
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        firstname = try node.extract("firstname")
        lastname = try node.extract("lastname")
        phone = try node.extract("phone")
        address = try node.extract("address")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "firstname": firstname,
            "lastname": lastname,
            "phone": phone,
            "address": address
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("addrs") { address in
            address.id()
            address.string("firstname")
            address.string("lastname")
            address.string("phone")
            address.string("address")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("addrs")
    }
}
