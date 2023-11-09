//
//  MainView.swift
//  CrossGate
//
//  Created by Gui Castro on 25/06/2023.
//

import SwiftUI

struct MainView: View {
    @State private var currentPage = "1"
    var body: some View {
        VStack{
            if currentPage == "0"{
                CalendarView(currentPage: $currentPage)
            }
            if currentPage == "1"{
                GroupsView(currentPage: $currentPage)
            }
            if currentPage == "2"{
                PaymentView(currentPage: $currentPage)
            }
            if currentPage == "3"{
                ChatView(currentPage: $currentPage)
            }
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
