//
//  SharedNetworking.swift
//  KoiPond
//
//  Created by Isabel  Lee on 12/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//  curl --data "param1=value1&param2=value2" https://example.com/resource.cgi
//  curl --data "name=isabel&username=ijlee" http://localhost:8080/adduser/
//  Attribution: http://stackoverflow.com/questions/22359090/get-current-nsdate-in-timestamp-format

import UIKit

// Track user time usage in app delegate
// Send Json as a string or a file
// Set the httpBody to jsonSerialization

class SharedNetworking {
    static let sharedInstance = SharedNetworking()
    private init() {}
    
    func postJson() {
        let data = ActionTracker.tracker.getData()
        let url = URL(string: "https://usertracker-164618.appspot.com/")!
        //let url = URL(string: "http:localhost:8080")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("/json/", forHTTPHeaderField: "Content-Type")
        request.addValue("/json/", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request as URLRequest,
                                    completionHandler: { data, response, error in
                                        //print(response!)
                                        //print(data!)
        })
        task.resume()
    }
    
    func jsonToData(jsonData: Data) {
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            guard let issues = json as? [String: AnyObject] else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            for (key, _) in issues {
                print("\(key)")
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func getJson(data: [String:Any]) {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            print(" This is Json data:")
            jsonToData(jsonData: jsonData)
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

//func simplePost() {
//    var request = URLRequest(url: URL(string: "https://usertracker-164618.appspot.com")!)
//    request.httpMethod = "POST"
//    let postString = "name=isabel&username=ijlee"
//    request.httpBody = postString.data(using: .utf8)
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        guard let data = data, error == nil else {                                                 // check for fundamental networking error
//            //print("error=\(error)")
//            return
//        }
//        
//        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//            print("statusCode should be 200, but is \(httpStatus.statusCode)")
//            //print("response = \(response)")
//        }
//        
//        let responseString = String(data: data, encoding: .utf8)
//        print("responseString = \(String(describing: responseString))")
//    }
//    task.resume()
//}
