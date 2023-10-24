//
//  ReefReferralExampleApp.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

@main
struct ReefReferralExampleApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        await ReefReferral.shared.start(apiKey:"f342a916-d682-4798-979e-873a74cc0b33")
                    }
                }
                .onOpenURL { url in
                    Task {
                        await ReefReferral.shared.handleDeepLink(url: url)
                    }
                }
        }
    }
}
