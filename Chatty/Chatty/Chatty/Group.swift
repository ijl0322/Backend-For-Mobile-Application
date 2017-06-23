//
//  Group.swift
//  Chatty
//
//  Created by Isabel  Lee on 30/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import UIKit

class Group {
    var groupId = ""
    var groupName = ""
    init(groupInfo: [String:Any], groupId: String) {
        self.groupName = groupInfo["name"] as! String
        self.groupId = groupId
    }
}
