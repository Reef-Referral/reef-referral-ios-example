//
//  ContentView.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

let API_KEY = "12b5831a-c4eb-4855-878f-e5fdacce8e18"

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @ObservedObject private var reef = ReefReferral.shared

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Referring Status")) {
                    if let linkURL = reef.referringLinkURL { // Access reef object properties
                        Button(linkURL.absoluteString) {
                            openURL(linkURL)
                        }
                        Text("\(reef.receivedCount) received")
                        Text("\(reef.successCount) success")
                        Text("\(reef.rewardEligibility.rawValue)")
                        if let rewardURL = reef.rewardURL {
                            Button(rewardURL.absoluteString) {
                                openURL(rewardURL)
                            }
                        }
                        if reef.rewardEligibility != .granted {
                            Button("Trigger Referring Success") {
                                reef.triggerReferringSuccess()
                            }
                        }
                        
                        Button("Clear Referral") {
                            Task {
                                reef.clear()
                            }
                        }
                        .foregroundColor(Color.red)
                    } else {
                        Text("No info")
                    }
                }
                
                Section(header: Text("Referred Status")) {
                    if reef.referredStatus != .none {
                        Text(reef.referredStatus.rawValue)
                        if let referredOfferURL = reef.referredOfferURL {
                            Button(referredOfferURL.absoluteString) {
                                openURL(referredOfferURL)
                            }
                        }
                        Button("Trigger Referral Success") {
                            reef.triggerReferralSuccess()
                        }
                    } else {
                        Text("Not a referred user")
                    }
                }

            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Reef Referral", displayMode: .large)
            .onAppear {
                reef.start(apiKey: API_KEY, logLevel: .trace)
            }
            .onOpenURL { url in
                reef.handleDeepLink(url: url)
            }
        }
    }
}

#Preview {
    ContentView()
}
