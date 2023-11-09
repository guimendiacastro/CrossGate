//
//  ChatLogView.swift
//  CrossGate
//
//  Created by Gui Castro on 04/07/2023.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI


struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let profileImageUrl = "profileImageUrl"
    static let name = "name"
    static let email = "email"
}



struct ChatMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}


class MessageSenderModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var currentMessage = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var count = 0
    @Published var chatUser: ChatUser?
    var chattingWith : ChatUser?
    
    init(chattingWith: ChatUser?) {
        self.chattingWith = chattingWith
        fetchCurrentUser()
        fetchMessages()
        
    }
    func fetchCurrentUser(){
        guard let uid =
                FirebaseManager.shared.auth.currentUser?.uid else{
            print("Not able to fetch current User")
            return}
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument{snapshot, error in
            if let error = error {self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return}
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            self.chatUser = .init(data: data)
        }
        
    }
    
    var firestoreListener: ListenerRegistration?
    func fetchMessages(){
        print("workedd")
        //print(chattingWith)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { print("Didint work from")
            return }
        guard let toId = chattingWith?.uid else { print("Didint work to")
                                                        return }
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                })
                DispatchQueue.main.async {
                    self.count += 1
                }
                
            }
       
        

    }
    
    func SendMessage(){
        self.fetchCurrentUser()
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chattingWith?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.currentMessage, "timestamp": Timestamp()] as [String : Any]
        
        document.setData(messageData) { err in
            if let err = err {
                print(err)
                self.errorMessage = "\(err)"
                return
            }}
        
        // The store for the reciever
        
        let document_reciever = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        
        document_reciever.setData(messageData) { err in
            if let err = err {
                print(err)
                self.errorMessage = "\(err)"
                return
            }}
        
        // recent messages
        
        let document_recent = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(fromId)
            .collection("messages")
            .document(toId)
        
        let messageData_recent = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.currentMessage, "timestamp": Timestamp(), FirebaseConstants.profileImageUrl: chattingWith?.profileImageUrl ?? "", FirebaseConstants.name: chattingWith?.name ?? "", FirebaseConstants.email: self.chattingWith?.email ?? ""] as [String : Any]
        document_recent.setData(messageData_recent){ err in
            if let err = err {
                print(err)
                self.errorMessage = "\(err)"
                return
            }}
        
        // The store for the reciever

        let document_reciever_recent = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(toId)
            .collection("messages")
            .document(fromId)
        let messageData_reciever_recent = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.currentMessage, "timestamp": Timestamp(), FirebaseConstants.profileImageUrl: self.chatUser?.profileImageUrl ?? "", FirebaseConstants.name: self.chatUser?.name ?? "", FirebaseConstants.email: self.chatUser?.email ?? ""] as [String : Any]
        document_reciever_recent.setData(messageData_reciever_recent){ err in
            if let err = err {
                print(err)
                self.errorMessage = "\(err)"
                return
            }}
        
       // self.putInRecentMessages()
        self.currentMessage = ""
        self.count += 1
    }
    

}

struct ChatLogView: View {
    
    @ObservedObject var vm: MessageSenderModel

    var body: some View {
        ZStack{
            Text(vm.errorMessage)
            VStack{
                MessagesView
                MessagesTabBarView
            }//.navigationTitle(Text(vm.chattingWith?.name ?? ""))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            WebImage(url: URL(string: vm.chattingWith?.profileImageUrl ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipped()
                                .cornerRadius(50)
                            Text(vm.chattingWith?.name ?? "").font(.headline)
                        }
                    }}
                .onDisappear {
                    vm.firestoreListener?.remove()
                }
        }
    }
    private var MessagesTabBarView: some View{
        HStack(spacing: 16){
            Image(systemName: "photo")
            ZStack {
                HStack{
                    Text("Aa")
                        .padding(.leading, 6.0)
                    Spacer()
                    
                }
              
                    TextEditor(text: $vm.currentMessage)
                        .opacity(vm.currentMessage.isEmpty ? 0.5 : 1)
                    
                }
                .frame(height: 40)
                
                Button{
                    vm.SendMessage()
                } label: {
                    Text("Send")
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
        }.padding(.horizontal)
            .padding(.vertical, 4)
            
    }
    private var MessagesView: some View{
        NavigationStack{
            ScrollView{
                ScrollViewReader { proxy in
                    VStack{
                        ForEach(vm.chatMessages) {messages in
                            if messages.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                                HStack{
                                    Spacer()
                                    VStack(){
                                        Text(messages.text)
                                        
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(Color.white)
                                            .padding()
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                        
                                        
                                        
                                    }.padding(.horizontal, 12)
                                    
                                    
                                }
                                .padding(6)
                            }
                            else{
                                HStack{
                                    
                                    VStack(){
                                        Text(messages.text)
                                        
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(Color.black)
                                            .padding()
                                            .background(Color(.systemGray5))
                                            .cornerRadius(8)
                                        
                                        
                                        
                                    }.padding(.horizontal, 12)
                                    Spacer()
                                    
                                }
                                .padding(6)
                            }
                            
                            
                        }
                        HStack{Spacer()}
                            .id("Empty")
                    }
                    .onReceive(vm.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo("Empty", anchor: .bottom)
                        } }
                }
            }
            
        }
        
    }}

//struct ChatLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatLogView(chattingWith: .init(data:["uid": "XJWs2cs2x0fFkeI7ANzpVJrrIkF3","email": "gui@gmail.com","profileImageUrl" :
//                                                "https://firebasestorage.googleapis.com:443/v0/b/crossgate-37de6.appspot.com/o/XJWs2cs2x0fFkeI7ANzpVJrrIkF3?alt=media&token=30ded171-65aa-491c-ac88-bedba54b3ee2"
//                                              ,"name": "Gui"]))
//    }
//}

