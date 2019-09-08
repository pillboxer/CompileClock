//
//  UserManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 05/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class UserManager {
    
    static func addToDatabase(_ user: User) {
        guard let id = user.id else {
            return
        }
        #warning("Be more safe here")
        let url = URL(string: "http://freddybean.compileclock.com/api/add_ccuser.php")!
        let json = ["uuid": "\(id)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        URLRequest.postRequestToURL(url, data: jsonData) { (response, error) in
            if let response = response {
                print(response.statusCode)
            }
        }
    }
    
}
