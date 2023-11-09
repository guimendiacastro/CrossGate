//
//  AddNewUsertoGroup.swift
//  CrossGate
//
//  Created by Gui Castro on 17/07/2023.
//
import SwiftUI
import SDWebImageSwiftUI


class AddNewUserViewModel: ObservableObject {
    
    @Published var users : [ChatUser] = []
    @Published var errorMessage = ""
   // @Published var groupUser = [String]()

    
    
//    func fetchAllUsers(groupUser: [String]) {
//        self.users.removeAll()
//        FirebaseManager.shared.firestore.collection("users")
//            .getDocuments { documentsSnapshot, error in
//                if let error = error {
//                    self.errorMessage = "Failed to fetch users: \(error)"
//                    print("Failed to fetch users: \(error)")
//                    return
//                }
//
//                documentsSnapshot?.documents.forEach({ snapshot in
//                    let data = snapshot.data()
//                    //let user = ChatUser(data: data)
//                   // print(type(of:(data)))
//                   // print(data)
//                   // if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
//                   // print((user.uid))
//                    //print(self.groupUsers)
//                    //if groupUser.contains(user.uid) == false {
//                        self.users.append(.init(data: data))
//                   // }
//
//                })
//
//            }
//    }
//    init(){
//        fetchAllUsers1()
//    }
     func fetchAllUsers1() {
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
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(.init(data: data))
                    }
                    
                })
            }
    }


}


struct AddNewUsertoGroup: View {
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.presentationMode) var presentationMode
    //@State var users = [ChatUser]()
    @State var groupUsers: [String]
    @State var test = ["hello", "again"]
    @State var errorMessage = ""
    
    
    //@ObservedObject var vm : AddNewUserViewModel
    @ObservedObject var vm = AddNewUserViewModel()
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
//                    ForEach(vm.users){user in
//                        Text(user.id)
//
//                    }
                    ForEach(vm.users){user in
                        Button{
                            presentationMode.wrappedValue.dismiss()
                            didSelectNewUser(user)
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
                        vm.fetchAllUsers1()
                    }
                
                    
                
            }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
           
        }
       
        
    }
}
