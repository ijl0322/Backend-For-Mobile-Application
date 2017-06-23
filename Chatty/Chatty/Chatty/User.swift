//
//  User.swift
//  Chatty
//
//  Created by Isabel  Lee on 30/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//
import UIKit
import Foundation
class User {
    var name = ""
    var avatar = UIImage(named: "user")
    
    init(name: String) {
        self.name = name
    }
}
