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
    @State private var showingReferralSheet = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("UI")) {
                    Button("Show Referral Sheet") {
                        showingReferralSheet = true
                    }
                    .sheet(isPresented: $showingReferralSheet) {
                        ReefReferralSheetView(apiKey:API_KEY,
                                              image: UIImage(imageLiteralResourceName: "share"),
                                              title: "One month free!",
                                              subtitle: "Invite your friends and claim your free month",
                                              description: "Your friends also get a free month, so it's a win for everyone!",
                                              footnote: "This is a footnote")
                    }
                }
                Section(header: Text("Referring Status")) {
                    if let linkURL = reef.referringLinkURL {
                        Button(linkURL.absoluteString) {
                            openURL(linkURL)
                        }
                        Text("\(reef.receivedCount) received")
                        Text("\(reef.redeemedCount) success")
                        Text("\(reef.rewardEligibility.rawValue)")
                        if let rewardURL = reef.referredRewardOfferCodeURL {
                            Button(rewardURL.absoluteString) {
                                openURL(rewardURL)
                            }
                        }
                        if reef.rewardEligibility != .redeemed {
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
                        if let referredOfferURL = reef.referredRewardOfferCodeURL {
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
            
        }
    }
}

#Preview {
    ContentView()
}
