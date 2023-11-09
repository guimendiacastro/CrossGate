//
//  CalendarView.swift
//  CrossGate
//
//  Created by Gui Castro on 25/06/2023.
//

import SwiftUI

struct CalendarView: View {
    @Binding var currentPage: String
    var body: some View {
        VStack{
            Text("Calendar")
            TabView(currentPage: $currentPage)
        }}
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(currentPage: .constant("0"))
    }
}
