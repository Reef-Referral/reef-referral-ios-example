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

    @State private var referralLinkURL: URL? = ReefReferral.shared.referralLinkURL
    @State private var referralReceived: Int = ReefReferral.shared.referralReceived
    @State private var referralSuccess: Int = ReefReferral.shared.referralSuccess
    @State private var rewardEligibility: ReferringRewardStatus = ReefReferral.shared.rewardEligibility
    @State private var rewardURL: URL? = ReefReferral.shared.rewardURL
    
    @State private var referredStatus: ReferredStatus = ReefReferral.shared.referredStatus
    @State private var referralOfferURL: URL? = ReefReferral.shared.referralOfferURL

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Referring Status")) {
                    if let linkURL = referralLinkURL {
                        Button(linkURL.absoluteString) {
                            openURL(linkURL)
                        }
                        Text("\(referralReceived) received")
                        Text("\(referralSuccess) success")
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
                        if let referralOfferURL {
                            Button(referralOfferURL.absoluteString) {
                                openURL(referralOfferURL)
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
                ReefReferral.shared.start(apiKey: API_KEY, delegate: self)
                ReefReferral.logger.logLevel = .trace
            }
            .onOpenURL { url in
                ReefReferral.shared.handleDeepLink(url: url)
            }
        }
    }
}

extension ContentView: ReefReferralDelegate {
    
    func referringUpdate(linkURL: URL?, received: Int, successes: Int, rewardEligibility: ReferringRewardStatus, rewardURL: URL?) {
        self.referralLinkURL = linkURL
        self.referralReceived = received
        self.referralSuccess = successes
        self.rewardEligibility = rewardEligibility
        self.rewardURL = rewardURL
    }
    
    func referredUpdate(status: ReferredStatus, offerURL: URL?) {
        self.referredStatus = status
        self.referralOfferURL = offerURL
    }
    
}

#Preview {
    ContentView()
}
