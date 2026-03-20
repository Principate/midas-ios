//
//  MidasApp.swift
//  Midas
//
//  Created by Bruno Lemus on 17/3/26.
//

import ClerkKit
import ClerkKitUI
import SwiftUI

@main
struct MidasApp: App {

    @State private var clerk = Clerk.configure(
        publishableKey:
            "pk_test_aGFwcHktY3Jhd2RhZC03Ni5jbGVyay5hY2NvdW50cy5kZXYk"
    )

    var body: some Scene {
        WindowGroup {
            if clerk.user != nil {
                MainTabView()

            } else {
                AuthView()
            }
        }
        .environment(clerk)
    }
}
