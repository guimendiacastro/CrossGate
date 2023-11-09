//
//  TabView.swift
//  CrossGate
//
//  Created by Gui Castro on 25/06/2023.
//

import SwiftUI

struct TabView: View {
    @Binding var currentPage: String
    var body: some View {
        Spacer()
        HStack{
            Spacer()
            Button {
                currentPage = "0"
            } label: {
                VStack (alignment: .center, spacing: 4) {
                    Image (systemName: "calendar")
                        .resizable ()
                        .scaledToFit ()
                        .frame (width: 40, height: 40)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            
            Spacer()
        Button {
            currentPage = "1"
        } label: {
            VStack (alignment: .center, spacing: 4) {
                Image (systemName: "person.2.fill")
                    .resizable ()
                    .scaledToFit ()
                    .frame (width: 40, height: 40)
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
            
            Spacer()
            
            Button {
                currentPage = "2"
            } label: {
                VStack (alignment: .center, spacing: 4) {
                    Image (systemName: "dollarsign.circle")
                        .resizable ()
                        .scaledToFit ()
                        .frame (width: 40, height: 40)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            Spacer()
            Button {
                currentPage = "3"
            } label: {
                VStack (alignment: .center, spacing: 4) {
                    Image (systemName: "bubble.left")
                        .resizable ()
                        .scaledToFit ()
                        .frame (width: 40, height: 40)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            Spacer()
        }
        .padding(.bottom, 8.0)

      
    }
}

//struct TabView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabView()
//    }
//}
