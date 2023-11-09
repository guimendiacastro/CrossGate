//
//  ContentView.swift
//  CrossGate
//
//  Created by Gui Castro on 22/06/2023.
//

import SwiftUI

struct ContentView: View {
    @State var Name = "My Lover"
    var listBar: [String] = ["bubble.left", "calendar", "lightbulb", "dollarsign.circle"]
    var body: some View {
        NavigationView{
            ZStack{
                //            Color(.systemGray6)
                //                .ignoresSafeArea()
                HStack{
                    Spacer()
                    VStack{
                        VStack{
                            NavigationLink(destination: RemindersView(Name: $Name)){
                                VStack (alignment: .center, spacing: 4) {
                                    Image (systemName: "lightbulb")
                                        .resizable ()
                                        .scaledToFit ()
                                        .frame (width: 40, height: 40)
                                    Text ("Reminders")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                .padding(.bottom)
                            }}
                        NavigationLink(destination: ContentView()){
                            VStack (alignment: .center, spacing: 4) {
                                Image (systemName: "calendar")
                                    .resizable ()
                                    .scaledToFit ()
                                    .frame (width: 40, height: 40)
                                Text ("Calendar")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                            }}
                    }
                    Spacer()
                    VStack{
                        VStack{
                            NavigationLink(destination: RemindersView(Name: $Name)){
                                VStack (alignment: .center, spacing: 4) {
                                    Image (systemName: "lightbulb")
                                        .resizable ()
                                        .scaledToFit ()
                                        .frame (width: 40, height: 40)
                                    Text ("Reminders")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                .padding(.bottom)
                            }}
                        NavigationLink(destination: ContentView()){
                            VStack (alignment: .center, spacing: 4) {
                                Image (systemName: "calendar")
                                    .resizable ()
                                    .scaledToFit ()
                                    .frame (width: 40, height: 40)
                                Text ("Calendar")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                            }}
                    }
                    Spacer()
                    
                }}
        }
        
    }
    func ButtonMod(){
        Name = ("Kirsty is my lover")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
