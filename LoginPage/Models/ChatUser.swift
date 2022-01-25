//
//  ChatUser.swift
//  WeText
//
//  Created by Santhosh Srinivas on 15/12/21.
//

import Foundation
//import FirebaseFirestoreSwift

struct ChatUser: Identifiable {
    
//    let timestamp: Date
    var id: String{
        uid
    }
//    var username: String {
//        email.components(separatedBy: "@").first ?? email
//    }
    
    let uid, phno : String
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.phno = data["phno"] as? String ?? ""
    }
}
