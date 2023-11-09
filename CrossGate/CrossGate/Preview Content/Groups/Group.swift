//
//  Group.swift
//  CrossGate
//
//  Created by Gui Castro on 14/07/2023.
//

import Foundation
struct GroupOfPeople: Identifiable {
    var id: String { uid }
    let uid, name, profileImageUrl, timestamp: String
    let users: [String]
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.timestamp = data["timestamp"] as? String ?? ""
        self.users = data["users"] as? [String] ?? [""]
    }
}
