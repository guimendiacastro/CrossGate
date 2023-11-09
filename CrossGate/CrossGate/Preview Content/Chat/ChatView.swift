//
//  ChatView.swift
//  CrossGate
//
//  Created by Gui Castro on 26/06/2023.
//
import Swift
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImageSwiftUI
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable{
    @DocumentID var id: String?
    let name: String
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Date
    
//    init(documentId: String, data: [String: Any]) {
//        self.documentId = documentId
//        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
//        self.toId = data[FirebaseConstants.toId] as? String ?? ""
//        self.text = data[FirebaseConstants.text] as? String ?? ""
//        self.timestamp = data["timestamp"] as? String ?? ""
//        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
//        self.name = data[FirebaseConstants.name] as? String ?? ""
//        self.email = data[FirebaseConstants.email] as? String ?? ""
//    }
}


class MessageViewModel: ObservableObject{
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isLoggedOut = false
    @Published var recent_chatMessages = [RecentMessage]()
    @Published var conv_recent_chatMessages = [ChatUser]()
    
    init(){
        DispatchQueue.main.async {
            self.isLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        getRecentMessages()
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
    func handlesignout(){
        isLoggedOut = true
        try? FirebaseManager.shared.auth.signOut()
    }
    private var firestoreListener: ListenerRegistration?
    func getRecentMessages(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        firestoreListener?.remove()
        conv_recent_chatMessages.removeAll()
        recent_chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(fromId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    if let index = self.recent_chatMessages.firstIndex(where: {
                        rm in
                        return rm.id == docId
                    }) {
                        self.recent_chatMessages.remove(at: index)
                    }
                    do {
                        let rm = try change.document.data(as: RecentMessage.self)
                            self.recent_chatMessages.insert(rm, at: 0)
                        
                    } catch {
                        print(error)
                    }
                    
                    
//                    self.recent_chatMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                   // self.convertRecenttoChatUser()
                    
                })
            }
       
    }

}
struct ChatView: View {
    @Binding var currentPage: String
    @State var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MessageViewModel()
    @State var showNewChat = false
    @State var chattingWith : ChatUser?
    @State var shouldNavigateToChatLogView = false
    var  messageSenderModel = MessageSenderModel(chattingWith: nil)
    private var newMessageButton: some View {
        Button{
            showNewChat.toggle()
        } label: {
            HStack{
                VStack{
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                }
                
            }
            .padding()
        }.padding()
            .fullScreenCover (isPresented: $showNewChat,
                              onDismiss: nil) {
                AddNewUserView(didSelectNewUser: {
                    user in
                    print(user.name)
                    self.chattingWith = user
                    shouldNavigateToChatLogView.toggle()
                    self.messageSenderModel.chattingWith = user
                    self.messageSenderModel.fetchCurrentUser()
                    self.messageSenderModel.fetchMessages()
                })
            }
        
    }
    
    
    private var customNavBar: some View {
       
        ScrollView {
            VStack(spacing: 20) {
               ForEach(vm.recent_chatMessages){message in
                        Button{
                            let uid = FirebaseManager.shared.auth.currentUser?.uid == message.fromId ? message.toId : message.fromId
                            
                            let temp = ["id": uid, "uid": uid, "email": message.email, "profileImageUrl": message.profileImageUrl, "name": message.name]
                            shouldNavigateToChatLogView.toggle()
                            self.messageSenderModel.chattingWith = .init(data:temp)
                            self.messageSenderModel.fetchCurrentUser()
                            self.messageSenderModel.fetchMessages()
                            
                        } label: {
                            HStack(spacing: 20){
                                WebImage(url: URL(string: message.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .cornerRadius(50)
                                    .overlay(RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                                    )
                                    .shadow(radius: 5)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(message.name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(.darkGray))
                                HStack {
                                    Text(message.text)
                                        .font(.system(size: 25))
                                        .foregroundColor(Color(.lightGray))
                                }
                            }
                            Spacer()
                        }
                        
                        
                    }
                }
               
                
            }
            .padding()
            
        }
        
    }
    
    private var currentUserNavBar: some View {
        HStack{
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            Text(vm.chatUser?.name ?? "Sorry Mate")
                .font(.system(size: 20, weight: .bold))
            Spacer()
            
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
            
        }.padding()
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                    .destructive(Text("Sign Out"), action: {
                        print("handle sign out")
                        shouldShowLogOutOptions.toggle()
                        vm.handlesignout()
                    }),
                    .cancel()
                ])
            }
            .fullScreenCover (isPresented: $vm.isLoggedOut,
                              onDismiss: nil) {
                LoginView(completedLogin: {
                    self.vm.isLoggedOut = false
                    self.vm.fetchCurrentUser()
                    self.vm.getRecentMessages()
                    //self.vm.convertRecenttoChatUser()
                })
            }
    }
   
    
    
    var body: some View {
        
        VStack{
            NavigationView{
                VStack{
                    currentUserNavBar
                    customNavBar
                    
                    NavigationLink("", isActive: $shouldNavigateToChatLogView){
                       // ChatLogView(chattingWith: self.chattingWith)
                        ChatLogView(vm: messageSenderModel)
                    }
                    
                }.overlay(newMessageButton, alignment: .bottomTrailing)
                    .navigationBarHidden(true)
            }
            TabView(currentPage: $currentPage)
        }
        
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(currentPage: .constant("0"))
    }
}
