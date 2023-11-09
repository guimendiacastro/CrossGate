//
//  Reminder1View.swift
//  CrossGate
//
//  Created by Gui Castro on 26/06/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI

struct NewGroup: Identifiable{
    var id: String { documentId }
    
    let documentId: String
    let text, timestamp, profileImageUrl, name, email: String}

class GroupsViewModel : ObservableObject {
    @Published var currentUser : ChatUser?
    @Published var isLoggedOut = false
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var groups = [GroupOfPeople]()
    init(){
        DispatchQueue.main.async {
            self.isLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
            self.fetchCurrentUser()
            
        }
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
            self.currentUser = .init(data: data)
            self.fetchAllGroups()
        }
        
        
    }
    func fetchAllGroups(){
        self.groups.removeAll()
        FirebaseManager.shared.firestore.collection("groups").order(by: "timestamp")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    //print(data)
                    let user = GroupOfPeople(data: data)
                   // print(type(of:(data)))
                   // print(data)
                    if user.users.contains(self.currentUser?.uid ?? "") {
                        self.groups.append(.init(data: data))
                    }
                    //print(self.groups)
                    
                })
            }
        
    }
   

}


struct GroupsView: View {
    @ObservedObject private var vm = GroupsViewModel()
    @Binding var currentPage: String
    @State var showNewGroup = false
    @State var image: UIImage?
    @State var NewGroupName = ""
    @State var errorMessage = ""
    @State var shouldNavigateToGroupInfoView = false
    @State var currentGroup: GroupOfPeople?
    func persistImageToStorage() {
//        let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.1) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.errorMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.errorMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                
                self.errorMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
               
                guard let url = url else{ return }
                self.storeUserInformation(imageProfileUrl: url)
                
            }
        }
    }
    private func storeUserInformation(imageProfileUrl: URL) {
        let uid = vm.currentUser?.id ?? ""
        let filename = UUID().uuidString
        let groupData = ["uid": filename, "profileImageUrl": imageProfileUrl.absoluteString,"name" :  NewGroupName, "timestamp": Timestamp() ,"users": [uid]] as [String : Any]
        Firestore.firestore().collection("payments")
            .document(filename).collection(uid).document("Lent").setData(["0": "0"] as [String : Any])
        Firestore.firestore().collection("payments")
            .document(filename).collection(uid).document("Borrowed").setData(["0": "0"] as [String : Any])
        FirebaseManager.shared.firestore.collection("groups")
            .document(filename).setData(groupData as [String : Any]) { err in
                if let err = err {
                    print(err)
                    self.errorMessage = "\(err)"
                    return
                }
                
                print("Success")
                vm.fetchAllGroups()
            }
       
    }
    
    var AllGroups: some View {
    
                VStack{
                 //   Text(errorMessage)
                HStack{
                    Spacer()
                    Button{
                        showNewGroup.toggle()
                    } label: {
                        Image (systemName: "person.2.fill")
                            .resizable ()
                            .scaledToFit ()
                            .frame (width: 40, height: 40)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                        
                    }
                    .padding(30.0)
                    
                    NavigationView{
                        ScrollView{
                            VStack{
                                ForEach(vm.groups){group in
                                    Button{
                                        shouldNavigateToGroupInfoView.toggle()
                                        self.currentGroup = group
                                    } label: {
                                        HStack{
                                            WebImage(url: URL(string: group.profileImageUrl ))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .clipped()
                                                .cornerRadius(50)
                                                .overlay(RoundedRectangle(cornerRadius: 44)
                                                    .stroke(Color(.label), lineWidth: 1)
                                                )
                                                .shadow(radius: 5)
                                            Text(group.name).foregroundColor(Color(.label))
                                            
                                        }.padding(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                        
                                    }
                                    Divider()
                                        .frame(height: 1)
                                        .padding(.horizontal, 30)
                                    .background(Color(.systemGray6))
                                }
                            }
                        }}
                    
                    
                    //CreateNewGroupView(test: $vm.currentUser)
              //  }
                    Spacer()
                }
                .fullScreenCover (isPresented: $vm.isLoggedOut,
                               onDismiss: nil) {
                 LoginView(completedLogin: {
                     self.vm.isLoggedOut = false
                 })}
                .fullScreenCover (isPresented: $showNewGroup,
                                  onDismiss: nil) {CreateNewGroupView(test: $vm.currentUser, didSelectNewUser: { user in
                 
                    image = user.image
                    persistImageToStorage()
                    NewGroupName = user.groupName
                    
                })
                        }
        
            }
    var body: some View{
        VStack{
            NavigationStack{
                VStack{
                    AllGroups
                   
                }.navigationDestination(isPresented: $shouldNavigateToGroupInfoView){
                    //GroupInfo(currentGroup: currentGroup)
                    GroupInfo(currentGroup: currentGroup)
                }
            }
            TabView(currentPage: $currentPage)
        }}
    
}
          


struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsView(currentPage: .constant("0"))
    }
}
