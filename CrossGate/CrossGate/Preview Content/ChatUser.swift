//
//  File.swift
//  CrossGate
//
//  Created by Gui Castro on 30/06/2023.
//

import Foundation

struct ChatUser: Identifiable, Hashable {
    var id: String { uid }
    let uid, email, profileImageUrl, name: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
    }
}
