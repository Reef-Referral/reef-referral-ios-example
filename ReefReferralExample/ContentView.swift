//
//  ContentView.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

let API_KEY = "976f07dc-6972-4e81-8497-64dfc4904abd";

extension ContentView: ReefReferralDelegate {
    
    func didReceiveReferralStatus(referralReceived: Int, referralSuccess: Int, rewardEligibility: RewardStatus) {
        print("didReceiveReferralStatus")
        self.referralReceived = referralReceived
        self.referralSuccess = referralSuccess
        self.rewardEligibility = rewardEligibility
    }
    
    func referredUserDidReceiveReferral() {
        print("referredUserDidReceiveReferral")
        self.referralID = ReefReferral.shared.data.referralId
        ReefReferral.shared.checkReferralStatus()
    }
    
    func referredUserDidClaimReferral() {
        print("referredUserDidClaimReferral")
        ReefReferral.shared.checkReferralStatus()
    }
    
    func referringUserDidClaimReward() {
        print("referringUserDidClaimReward")
        ReefReferral.shared.checkReferralStatus()
    }
    
}

struct ContentView: View {

    @Environment(\.openURL) var openURL
    
    @State private var referralLink: ReferralLinkContent? = ReefReferral.shared.data.referralLink
    @State private var referralID: String? = ReefReferral.shared.data.referralId
    @State private var referralReceived: Int = 0
    @State private var referralSuccess: Int = 0
    @State private var rewardEligibility: RewardStatus = .not_eligible
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Referring user")) {
                    if let link = referralLink {
                        Button(link.link_url) {
                            openURL(URL(string: link.link_url)!)
                        }
                        Button("Trigger Referring Success") {
                            ReefReferral.shared.triggerReferringSuccess()
                        }
                        Button("Clear Referral Link") {
                            Task {
                                referralLink = nil
                                ReefReferral.shared.clearLink()
                                referralID = nil
                                ReefReferral.shared.clearReferralID()
                                referralReceived = 0
                                referralSuccess = 0
                                rewardEligibility = .not_eligible
                            }
                        }.foregroundColor(Color.red)
                    } else {
                        Button("Generate Referral Link") {
                            Task {
                                referralLink = await ReefReferral.shared.generateReferralLink()
                                if let link = referralLink {
                                    UIPasteboard.general.string = "reef-referral://\(link.id)"
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Referred user")) {
                    if let ref = referralID {
                        Text(ref)
                        Button("Trigger Referral Success") {
                            ReefReferral.shared.triggerReferralSuccess()
                        }
                        Button("Clear referral ID") {
                            referralID = nil
                            ReefReferral.shared.clearReferralID()
                        }.foregroundColor(Color.red)
                    } else {
                        Text("No referral ID")
                    }
                }

                Section(header: Text("Referrals Status")) {
                    Text("\(self.referralReceived) received")
                    Text("\(self.referralSuccess) success")
                    Text("Reward Eligibility : \(self.rewardEligibility.rawValue)")
                    Button("Refresh") {
                        ReefReferral.shared.checkReferralStatus()
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Reef Referral", displayMode: .large)
            .onAppear {
                ReefReferral.shared.start(apiKey:API_KEY, delegate: self)
                ReefReferral.logger.logLevel = .trace
                ReefReferral.shared.checkReferralStatus()
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
