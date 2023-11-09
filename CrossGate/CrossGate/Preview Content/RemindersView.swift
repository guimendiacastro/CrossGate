//
//  RemindersView.swift
//  CrossGate
//
//  Created by Gui Castro on 24/06/2023.
//

import SwiftUI

struct RemindersView: View {
    @Binding var Name: String
    @EnvironmentObject var profile: Profile
    var body: some View {
        VStack{
            if profile.isLoggedIn == true {
                Text(Name)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                TextField("", text:$Name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                Button(action: {
                profile.isLoggedIn = false
                }, label: {
                    Text ("Log out")})
            }
            else{
                Text("Please Login Mate")
                Button(action: {
                profile.isLoggedIn = true
                }, label: {
                    Text ("Log in")})
                }

        }
        
    }}

//struct RemindersView_Previews: PreviewProvider {
//    static var previews: some View {
//        RemindersView(Name: (.constant("hello")))
//    }
//}
