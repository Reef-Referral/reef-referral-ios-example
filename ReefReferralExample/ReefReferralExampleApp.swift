//
//  ReefReferralExampleApp.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

let API_KEY = "12b5831a-c4eb-4855-878f-e5fdacce8e18"

@main
struct ReefReferralExampleApp: App {
        
    init() {
        ReefReferral.shared.start(apiKey: API_KEY, logLevel: .debug)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
            .onOpenURL { url in
                ReefReferral.shared.handleDeepLink(url: url)
            }
        }
    }
}
