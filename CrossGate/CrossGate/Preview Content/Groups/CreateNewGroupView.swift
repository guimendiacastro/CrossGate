//
//  CreateNewGroupView.swift
//  CrossGate
//
//  Created by Gui Castro on 12/07/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI

struct GroupNameAndImage{
    let groupName: String
    let image: UIImage?
//    init(groupName:String, image:UIImage){
//        self.groupName = groupName
//        self.image = image
//    }
}
    

struct CreateNewGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var test : ChatUser?
    @State private var shouldShowImagePicker = false
    @State var GroupName = ""
    @State var image: UIImage?
    let didSelectNewUser: (GroupNameAndImage) -> ()
    //@State var final_ouptut = GroupNameAndImage()
    var body: some View {
        NavigationView{
                VStack{
                    HStack{
                        Button{
                            shouldShowImagePicker.toggle()
                        } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable ()
                                .scaledToFit ()
                                .frame (width: 30, height: 30)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .padding(.trailing)
                       
                        VStack(alignment: .leading){
                            Text("Group Name")
                                
                            TextField("", text: $GroupName)
                            Divider()
                                .frame(height: 1)
                                .padding(.horizontal, 30)
                            .background(Color(.systemGray6))}
                    }
                    .padding(.horizontal, 15.0)
                    
                    Spacer()
                    
                    
                }.padding(.vertical, 20.0)
                    .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                        ImagePicker(image: $image)
                        
                    }
                
                    .navigationTitle("Create a New Group")
                    .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItemGroup(placement:.navigationBarTrailing ) {
                                
                                Button {
                                    let final_ouptut = GroupNameAndImage(groupName: GroupName, image: image)
                                    didSelectNewUser(final_ouptut)
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Text("Done")
                                }
                            }
                            ToolbarItemGroup(placement:.navigationBarLeading ) {
                                    Button {
                                        presentationMode.wrappedValue.dismiss()
                                    } label: {
                                        Text("Cancel")
                                    }
            
                                
                            }
                        }
            }
       
        }}
    


struct CreateNewGroupView_Previews: PreviewProvider {
    static var previews: some View {
        
       let test = ["uid": "XJWs2cs2x0fFkeI7ANzpVJrrIkF3","email": "gui@gmail.com","profileImageUrl" :"https://firebasestorage.googleapis.com:443/v0/b/crossgate-37de6.appspot.com/o/XJWs2cs2x0fFkeI7ANzpVJrrIkF3?alt=media&token=30ded171-65aa-491c-ac88-bedba54b3ee2","name": "Gui"]
        let test2 = ChatUser(data: test)
        CreateNewGroupView(test: .constant(test2), didSelectNewUser: {_ in })
    }
}
