//
//  AddNewUserView.swift
//  CrossGate
//
//  Created by Gui Castro on 03/07/2023.
//

import SwiftUI
import SDWebImageSwiftUI

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
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


struct AddNewUserView: View {
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
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
//
//struct AddNewUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddNewUserView(didSelectNewUser: )
//    }
//}
