//
//  SwiftUIView.swift
//  CrossGate
//
//  Created by Gui Castro on 12/07/2023.
//

import SwiftUI
import Foundation
import FirebaseStorage
import Firebase
import SDWebImageSwiftUI



class GroupInfoViewModel: ObservableObject {
    
    @Published var users: [ChatUser] = []
    @Published var usersFinal : [String] = []
    @Published var errorMessage = ""
   // @Published var groupUser = [String]()

    
    func fetchAllUsers(groupUser: [String]) {
        self.users.removeAll()
        self.usersFinal.removeAll()
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }

                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                   // print(type(of:(data)))
                   // print(data)
                   // if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                   // print((user.uid))
                    //print(self.groupUsers)
                    print(user.name)
                    if groupUser.contains(user.id) == true {
                        self.users.append(.init(data: data))
                        let temp = user.name
                        print(temp, "temp")
                        self.usersFinal.append(temp)
                    }
                    
                })
                print(self.usersFinal)
            }
       
    }
    


}

struct GroupInfo: View {
    @ObservedObject private var vm = GroupInfoViewModel()
    @State var showNewUser = false
    @State var currentGroup: GroupOfPeople?
    @State var addedUser : ChatUser?
    @State var errorMessage = ""
    @State var currentGroupUsers = [""]
    // @State var groupUsers1 = [String]?.self
    var addNewUserViewModel = AddNewUserViewModel()
    
    func getGroupUsers () {
        FirebaseManager.shared.firestore.collection("groups").document(currentGroup?.uid ?? "")
            .getDocument{ (document, error) in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                let data = document!.data()
                currentGroup = GroupOfPeople(data: data!)
            }
        currentGroupUsers = currentGroup?.users ?? []
        vm.fetchAllUsers(groupUser: currentGroup?.users ?? [])
    }
    //private var firestoreListener: ListenerRegistration?
    //private mutating func getGroupUsers(){
    //        firestoreListener?.remove()
    //        firestoreListener = FirebaseManager.shared.firestore
    //            .collection("groups")
    //            .document(currentGroup?.id ?? "")
    //            .addSnapshotListener {querySnapshot, error in
    //                if let error = error {
    //                    errorMessage = "Failed to listen for messages: \(error)"
    //                    print(error)
    //                    return
    //                }
    //
    //                querySnapshot?.data()?.forEach({ queryDocumentSnapshot in
    //                   // let data = queryDocumentSnapshot.data()
    //                    print(queryDocumentSnapshot)
    //                })
    //                                                 }
    //                                                 }
    //
    // }
    
    
    func addUser(){
        let document_recent = FirebaseManager.shared.firestore
            .collection("groups")
            .document(currentGroup?.id ?? "")
        var newUsers = currentGroup?.users ?? []
        let temp = addedUser?.id ?? ""
        newUsers.append(temp)
        Firestore.firestore().collection("payments")
            .document(currentGroup?.id ?? "").collection(temp).document("Lent").setData(["0": "0"] as [String : Any])
        Firestore.firestore().collection("payments")
            .document(currentGroup?.id ?? "").collection(temp).document("Borrowed").setData(["0": "0"] as [String : Any])
        let messageData_recent = [FirebaseConstants.name: currentGroup?.name ?? "", FirebaseConstants.profileImageUrl: currentGroup?.profileImageUrl ?? "", "timestamp": Timestamp(), "uid": currentGroup?.uid ?? "", "users": newUsers] as [String : Any]
        document_recent.setData(messageData_recent){ err in
            if let err = err {
                print(err)
                self.errorMessage = "\(err)"
                return
            }}
        currentGroupUsers = newUsers
    }
    
    var groupUsersView: some View {
        ScrollView{
            VStack{
            }
            ForEach(vm.users){user in
                Button{
                } label: {
                    HStack{
                        WebImage(url: URL(string: user.profileImageUrl ))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipped()
                            .cornerRadius(50)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                            )
                            .shadow(radius: 5)
                        Text(user.name).foregroundColor(Color(.label))
                    }
                    Spacer()
                }.padding(.horizontal)
                Divider()
                    .padding(.vertical, 8)
                
                
            }
        }.onAppear{
            self.getGroupUsers()
        }
    }
    
    var body: some View {
        
        VStack{
            //   Text(errorMessage)
            //            let temp1 = currentGroup?.users ?? []
            //            ForEach(temp1, id: \.self){ user in
            //                Text(user)
            //            }
            
            HStack{
                Text(currentGroup?.name ?? "Not yet")
                Spacer()
                Button{
                    // self.addNewUserViewModel.fetchAllUsers(groupUser:  //currentGroup?.users ?? [])
                    showNewUser.toggle()
                } label: {
                    Image (systemName: "person.badge.plus")
                        .resizable ()
                        .scaledToFit ()
                        .frame (width: 40, height: 40)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            
            //                List(vm.usersFinal, id: \.self){ user in
            //                    Text(user)
            //                }
            //                .onAppear{
            //                    self.getGroupUsers()
            //                    //vm.fetchAllUsers(groupUser: currentGroup?.users ?? [])
            //                }
            
            //                .refreshable {
            //                    self.getGroupUsers()
            //                    vm.fetchAllUsers(groupUser: currentGroup?.users ?? [])
            //                }
            
            .padding(30.0)
            Spacer()
            
            groupUsersView
        }
        .fullScreenCover (isPresented: $showNewUser,
                          onDismiss: nil) {
            AddNewUsertoGroup(didSelectNewUser: {
                user in
                self.addedUser = user
                self.addUser()
                currentGroupUsers = currentGroup?.users ?? []
                currentGroupUsers.append(user.id)
            
                print(currentGroupUsers)
            }, groupUsers: currentGroupUsers)}
        
        
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        GroupInfo()
    }
}
