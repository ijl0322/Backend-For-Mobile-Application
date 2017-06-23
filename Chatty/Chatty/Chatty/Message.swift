//
//  Message.swift
//  Chatty
//
//  Created by Isabel  Lee on 30/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum MessageType {
    case image
    case text
}

class Message {
    var message:String?
    var image:UIImage?
    var messageType: MessageType
    var senderId: String
    
    init(sender: String, message: String?, image: UIImage?, messageType: MessageType){
        self.senderId = sender
        self.message = message
        self.image = image
        self.messageType = messageType
    }
    
}
