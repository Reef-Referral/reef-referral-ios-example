//
//  ContentView.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

let API_KEY = "9c7b2de7-12be-4e64-848b-cbecd308db1f"

struct ContentView: View {
    @Environment(\.openURL) var openURL

    @State private var linkURL: URL? = ReefReferral.shared.referringLinkURL
    @State private var receivedCount: Int = ReefReferral.shared.referringReceivedCount
    @State private var successCount: Int = ReefReferral.shared.referringSuccessCount
    @State private var rewardEligibility: ReferringRewardStatus = ReefReferral.shared.referringRewardEligibility
    @State private var rewardURL: URL? = ReefReferral.shared.referringRewardURL
    
    @State private var referredStatus: ReferredStatus = ReefReferral.shared.referredStatus
    @State private var referredOfferURL: URL? = ReefReferral.shared.referredOfferURL

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Referring Status")) {
                    if let linkURL = linkURL {
                        Button(linkURL.absoluteString) {
                            openURL(linkURL)
                        }
                        Text("\(receivedCount) received")
                        Text("\(successCount) success")
                        Text("\(rewardEligibility.rawValue)")
                        if let rewardURL {
                            Button(rewardURL.absoluteString) {
                                openURL(rewardURL)
                            }
                        }
                        if rewardEligibility != .granted {
                            Button("Trigger Referring Success") {
                                ReefReferral.shared.triggerReferringSuccess()
                            }
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
                
                Section(header: Text("Referred Status")) {
                    if referredStatus != .none {
                        Text(referredStatus.rawValue)
                        if let referredOfferURL {
                            Button(referredOfferURL.absoluteString) {
                                openURL(referredOfferURL)
                            }
                        }
                        Button("Trigger Referral Success") {
                            ReefReferral.shared.triggerReferralSuccess()
                        }
                    } else {
                        Text("Not a referred user")
                    }
                }

            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Reef Referral", displayMode: .large)
            .onAppear {
                ReefReferral.shared.start(apiKey: API_KEY, delegate: self, logLevel: .trace)
            }
            .onOpenURL { url in
                ReefReferral.shared.handleDeepLink(url: url)
            }
        }
    }
}

extension ContentView: ReefReferralDelegate {
    
    func referringUpdate(linkURL: URL?, received: Int, successes: Int, rewardEligibility: ReferringRewardStatus, rewardURL: URL?) {
        self.linkURL = linkURL
        self.receivedCount = received
        self.successCount = successes
        self.rewardEligibility = rewardEligibility
        self.rewardURL = rewardURL
    }
    
    func referredUpdate(status: ReferredStatus, offerURL: URL?) {
        self.referredStatus = status
        self.referredOfferURL = offerURL
    }
    
}

#Preview {
    ContentView()
}
