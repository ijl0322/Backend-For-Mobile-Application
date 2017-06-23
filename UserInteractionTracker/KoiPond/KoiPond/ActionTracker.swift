//
//  ActionTracker.swift
//  KoiPond
//
//  Created by Isabel  Lee on 14/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import UIKit
class ActionTracker {
    static let tracker = ActionTracker()
    //let id = UIDevice().identifierForVendor?.uuidString
    let id = "aaaa"
    var sessionStartTime = 0.0
    var sessionEndTime = 0.0
    var sessionDuration = 0.0
    var button1Clicked = 0
    var button2Clicked = 0
    let date = Date()
    let calendar = Calendar.current
    var year = 0
    var month = 0
    var day = 0
    var touchHeatMap: [[String: Double]] = []
    
    private init() {}
    
    func resetSession() {
        sessionStartTime = 0
        sessionEndTime = 0
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        day = calendar.component(.day, from: date)
        button1Clicked = 0
        button2Clicked = 0
        touchHeatMap = []
        print("Today is \(year)/\(month)/\(day)")
    }
    
    func setStartTime(time: Double) {
        sessionStartTime = time
        print("Session Start Time Recored: \(sessionStartTime)")
    }
    
    func sessionEnded(time: Double) {
        sessionEndTime = time
        sessionDuration = sessionEndTime - sessionStartTime
        print("Session End Time Recored: \(sessionEndTime)")
        sessionSummary()
    }
    
    func recordTouch(x: CGFloat, y: CGFloat) {
        touchHeatMap.append(["x": Double(x), "y": Double(y)])
    }
    
    func sessionSummary() {
        print("Session Duration: \(sessionDuration)")
        print("Button 1 was clicked \(button1Clicked) times")
        print("Button 2 was clicked \(button1Clicked) times")
        print("Number of touches recored: \(touchHeatMap.count)")
        print("Touch Position: ")
        for touch in touchHeatMap {
            print("x: \(String(describing: touch["x"])), y: \(String(describing: touch["y"]))")
        }
    }
    
    func getData() -> [String:Any] {
        let data = ["user": id, "sessionTime": sessionDuration, "events":["button1": button1Clicked, "button2": button2Clicked], "touches": touchHeatMap, "date" : ["year": year, "month": month, "day": day]] as [String : Any]
        return data
    }
}



