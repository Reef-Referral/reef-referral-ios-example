//
//  ContentView.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

struct ContentView: View, ReefReferralDelegate {
    
    func didReceiveReferralStatuses(_ statuses: [ReferralStatus]) {
        print("didReceiveReferralStatuses: \(statuses)")
        self.statuses = statuses
    }
        
    func wasReferredSuccessfully() {
        print("wasReferredSuccessfully")
        self.referralID = ReefReferral.shared.data.referralId
        ReefReferral.shared.checkReferralStatuses()
    }
    
    func wasConvertedSuccessfully() {
        print("wasConvertedSuccessfully")
        ReefReferral.shared.checkReferralStatuses()
    }

    @Environment(\.openURL) var openURL
    
    @State private var referralLink: ReferralLinkContent? = ReefReferral.shared.data.referralLink
    @State private var referralID: String? = ReefReferral.shared.data.referralId
    @State private var statuses: [ReferralStatus] = []
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Referring user")) {
                    if let link = referralLink {
                        Button(link.link_url) {
                            openURL(URL(string: link.link_url)!)
                        }
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
                            referralID = nil
                            ReefReferral.shared.clearReferralID()
                            statuses = []
                        }
                    }.foregroundColor(Color.red)
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
                    Text("\(self.statuses.filter({ $0.status == .received }).count) received")
                    Text("\(self.statuses.filter({ $0.status == .success }).count) success")
                    Button("Refresh") {
                        ReefReferral.shared.checkReferralStatuses()
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Reef Referral", displayMode: .large)
            .onAppear {
                ReefReferral.shared.start(apiKey:"f342a916-d682-4798-979e-873a74cc0b33", delegate: self)
                ReefReferral.logger.logLevel = .trace
                ReefReferral.shared.checkReferralStatuses()
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
