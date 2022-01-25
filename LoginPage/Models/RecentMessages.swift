//
//  RecentMessages.swift
//  WeText
//
//  Created by Santhosh Srinivas on 15/12/21.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    let text, phno: String
    let fromId, toId: String
    let timestamp: Date
    
//    var username: String {
//        email.components(separatedBy: "@").first ?? email
//    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
