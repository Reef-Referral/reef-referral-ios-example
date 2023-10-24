//
//  ContentView.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

struct ContentView: View {
    
    @State private var referralLink: ReferralLinkContent?
    @State private var referralID: String?
    @State private var statuses: [ReferralStatus] = []
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Referring user")) {
                    if let link = referralLink {
                        Text("reef-referral://\(link.id)")
                        
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
                    Button("Clear Referral Link") {
                        Task {
                            referralLink = nil
                            ReefReferral.shared.clearLink()
                        }
                    }.foregroundColor(Color.red)
                }
                
                Section(header: Text("Referred user")) {
                    if let ref = referralID {
                        Text(ref)
                    } else {
                        Button("Trigger Handle Deeplink") {
                            Task {
                                guard let link = referralLink,
                                      let url = URL(string:link.link_url)
                                else { return }
                                await ReefReferral.shared.handleDeepLink(url:url)
                                referralID = ReefReferral.shared.data.referralId
                            }
                        }
                    }
                    Button("Trigger Referral Success") {
                        Task {
                            await ReefReferral.shared.triggerReferralSuccess()
                        }
                    }
                    Button("Clear referral ID") {
                        Task {
                            referralID = nil
                            ReefReferral.shared.clearReferralID()
                        }
                    }.foregroundColor(Color.red)
                }

                Section(header: Text("Referrals Status")) {
                    Text("\(statuses.filter({ $0.status == .received }).count) received")
                    Text("\(statuses.filter({ $0.status == .success }).count) success")
                    Button("Refresh") {
                        Task{
                            statuses = await ReefReferral.shared.checkReferralStatuses()
                        }
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
