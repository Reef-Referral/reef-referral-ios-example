//
//  ContentView.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

let API_KEY = "9c7b2de7-12be-4e64-848b-cbecd308db1f";

struct ContentView: View {
    @Environment(\.openURL) var openURL

    @ObservedObject var reefReferralObservable: ReefReferralObservable

    init() {
        let reefReferral = ReefReferral.shared
        self.reefReferralObservable = ReefReferralObservable(reefReferral: reefReferral)
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Referral link URL")) {
                    if let linkURL = reefReferralObservable.referralLinkURL {
                        Button(linkURL.absoluteString) {
                            openURL(linkURL)
                        }
                        Button("Trigger Referring Success") {
                            ReefReferral.shared.triggerReferringSuccess()
                        }
                        Button("Clear Referral") {
                            Task {
                                ReefReferral.shared.clear()
                            }
                        }
                        .foregroundColor(Color.red)
                    } else {
                        Text("No info")
                    }
                }

                Section(header: Text("Referrals Status")) {
                    Text("\(reefReferralObservable.referralStatus.received) received")
                    Text("\(reefReferralObservable.referralStatus.success) success")
                    Text("Reward Eligibility : \(reefReferralObservable.referralStatus.eligibility.rawValue)")
                }
                
                Section() {
                    Button("Refresh Status") {
                        ReefReferral.shared.status()
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Reef Referral", displayMode: .large)
            .onAppear {
                ReefReferral.shared.start(apiKey: API_KEY, delegate: reefReferralObservable)
                ReefReferral.logger.logLevel = .trace
                ReefReferral.shared.status()
            }
            .onOpenURL { url in
                ReefReferral.shared.handleDeepLink(url: url)
            }
        }
    }
}


#Preview {
    ContentView()
}
