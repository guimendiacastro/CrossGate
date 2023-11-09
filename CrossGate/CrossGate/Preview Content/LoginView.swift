//
//  LoginView.swift
//  CrossGate
//
//  Created by Gui Castro on 27/06/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init ()
    }}

struct LoginView: View {
    let completedLogin: () -> ()
    @State private var isLoginMode = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    @State private var shouldShowImagePicker = false
    var body: some View {
            NavigationView {
                ScrollView {
                    Picker(selection: $isLoginMode, label: Text("Picker here")){
                        Text("Log In").tag(true)
                        Text("Create Account").tag(false)
                        
                    }.pickerStyle(SegmentedPickerStyle()).padding()
                    VStack{
                        if !isLoginMode {
                            Button{
                                shouldShowImagePicker.toggle()
                            } label: {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    Image (systemName: "person")
                                        .font (.system(size: 64))
                                        .padding()
                                }}
                        }
                        Group{
                            if !isLoginMode{
                                TextField("Name", text: $name)
                                    .keyboardType(.emailAddress)
                            }
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("password", text: $password)
                        }.padding(5)
                            .background(Color(white: 1))
                            .cornerRadius(25)
                        
                        Button{
                            handlebutton()
                            
                        } label: {
                            HStack{
                                Spacer()
                                Text(isLoginMode ? "Log In" : "Create Account")
                                    .foregroundColor(.black)
                                    .padding()
                                
                                Spacer()
                                
                            }.background(Color.blue)
                                .cornerRadius(25)
                            
                            
                            
                        }
                        .padding(.top, 5.0)
                        Text(self.errorMessage)
                            .foregroundColor(.red)
                    }.padding()
                }.navigationTitle(isLoginMode ? "Log In" : "Create Account")
                    .background(Color(.systemGray6))
                    
                
            }.navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
        
    }
        @State var image: UIImage?
    private func handlebutton(){
        if isLoginMode {
            loginUser()
        } else{
            createAccount()
        }
    }
    @State var errorMessage = ""
    private func createAccount(){
        if self.image == nil{
            self.errorMessage = "Select a Picture"
            return
        }
        if self.name == ""{
            self.errorMessage = "Please Provide your Name"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){ result, err in
            if let err = err{
                print("Failed to create User: ", err)
                self.errorMessage = "Failed to create user: \(err)"
                return
            }
            print ("Successfully created user: \(result?.user.uid ?? "")")
            self.errorMessage = "Successfully created user: \(result?.user.uid ?? "")"
            self.persistImageToStorage()
        }
    }
    private func persistImageToStorage() {
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
    
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){result, err in
            if let err = err{
                print("Failed to Log In: ", err)
                self.errorMessage = "Failed to Log In: \(err)"
                return
            }
            print ("Successfully Logged In: \(result?.user.uid ?? "")")
            self.errorMessage = "Successfully Logged In: \(result?.user.uid ?? "")"
            self.completedLogin()
        }
            
        }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return
            print("didnt work")
        }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString,"name" : self.name]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.errorMessage = "\(err)"
                    return
                }
                
                print("Success")
                self.completedLogin()
            }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(completedLogin: {})
    }
}
