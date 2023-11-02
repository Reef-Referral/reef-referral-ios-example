//
//  ContentView.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

let API_KEY = "976f07dc-6972-4e81-8497-64dfc4904abd";
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
                Section(header: Text("Referring user")) {
                    if let link = reefReferralObservable.referralLink {
                        Button(link.link_url) {
                            openURL(URL(string: link.link_url)!)
                        }
                        Button("Trigger Referring Success") {
                            ReefReferral.shared.triggerReferringSuccess()
                        }
                        Button("Clear Referral Link") {
                            Task {
                                reefReferralObservable.referralLink = nil
                                ReefReferral.shared.clearLink()
                                reefReferralObservable.referralID = nil
                                ReefReferral.shared.clearReferralID()
                            }
                        }
                        .foregroundColor(Color.red)
                    } else {
                        Button("Generate Referral Link") {
                            Task {
                                reefReferralObservable.referralLink = await ReefReferral.shared.generateReferralLink()
                                if let link = reefReferralObservable.referralLink {
                                    UIPasteboard.general.string = "reef-referral://\(link.id)"
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Referrals Status")) {
                    Text("\(reefReferralObservable.referralStatus.received) received")
                    Text("\(reefReferralObservable.referralStatus.success) success")
                    Text("Reward Eligibility : \(reefReferralObservable.referralStatus.eligibility.rawValue)")
                }
                
                Section() {
                    Button("Refresh Status") {
                        ReefReferral.shared.checkReferralStatus()
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Reef Referral", displayMode: .large)
            .onAppear {
                ReefReferral.shared.start(apiKey: API_KEY, delegate: reefReferralObservable)
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
