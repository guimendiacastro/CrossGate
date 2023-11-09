//
//  CrossGateApp.swift
//  CrossGate
//
//  Created by Gui Castro on 22/06/2023.
//

import SwiftUI

@main
struct CrossGateApp: App {
        var body: some Scene {
        WindowGroup {
                MainView()
                    .environmentObject (Profile ())
            }
        }
    }


