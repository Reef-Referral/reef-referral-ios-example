//
//  ContentView.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral

//let API_KEY = "12b5831a-c4eb-4855-878f-e5fdacce8e18" //Prod
let API_KEY = "8e599760-ec74-49fa-97dc-9f5162a1ac30" // Dev

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
                
                Section(header: Text("Sender Status")) {
                    if let linkURL = reef.senderLinkURL {
                        
                        Button(linkURL.absoluteString) {
                            openURL(linkURL)
                        }
                        
                        Text("\(reef.senderLinkReceivedCount) received")
                        Text("\(reef.senderLinkRedeemedCount) redeemed")
                        Text("\(reef.senderRewardEligibility.rawValue)")
                        
                        if let rewardURL = reef.senderRewardCodeURL {
                            Button(rewardURL.absoluteString) {
                                openURL(rewardURL)
                            }
                        }
                        if reef.senderRewardEligibility != .redeemed {
                            Button("Trigger Referring Success") {
                                reef.triggerSenderSuccess()
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
                
                Section(header: Text("Receiver Status")) {
                    if reef.receiverStatus != .none {
                        Text(reef.receiverStatus.rawValue)
                        if let receiverOfferCodeURL = reef.receiverOfferCodeURL {
                            Button(receiverOfferCodeURL.absoluteString) {
                                openURL(receiverOfferCodeURL)
                            }
                        }
                        Button("Trigger Referral Success") {
                            reef.triggerReceiverSuccess()
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
