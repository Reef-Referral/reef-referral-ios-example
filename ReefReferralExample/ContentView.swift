//
//  ContentView.swift
//  ReefReferralExample
//
//  Created by Alexis Creuzot on 23/10/2023.
//

import SwiftUI
import ReefReferral


extension ContentView {
    class ViewModel: ObservableObject, ReefReferralDelegate {
        @Published var reef: ReefReferral.ReferralInfo?

        func infoUpdated(referralInfo: ReefReferral.ReferralInfo) {
            self.reef = referralInfo
        }
    }
}

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @StateObject private var vm = ViewModel()
    @State private var showingReferralSheet = false

    var body: some View {
        NavigationView {
            List {

                if let reef = vm.reef {
                    Section(header: Text("UI")) {
                        Button("Show Referral Sheet") {
                            showingReferralSheet = true
                        }   
                        .sheet(isPresented: $showingReferralSheet) {
                            ReefReferralSheetView(reef: $vm.reef,
                                                  image: UIImage(imageLiteralResourceName: "share"),
                                                  title: "One month free!",
                                                  subtitle: "Invite your friends and claim your free month",
                                                  description: "Your friends also get a free month, so it's a win for everyone!",
                                                  footnote: "This is a footnote")
                        }
                    }

                    Section(header: Text("Sender Status")) {
                        if let linkURL = reef.senderInfo.linkURL {

                            Button("Set custom ID") {
                                ReefReferral.shared.setUserId("custom_id_test a as @@.com")
                            }

                            Button(linkURL.absoluteString) {
                                openURL(linkURL)
                            }

                            Text("\(reef.senderInfo.redeemedCount ) redeemed")
                            Text("\(reef.senderInfo.rewardEligibility.rawValue )")

                            if let rewardURL = reef.senderInfo.offerCodeURL {
                                Button(rewardURL.absoluteString) {
                                    openURL(rewardURL)
                                }
                            }
                            if reef.senderInfo.rewardEligibility != .redeemed {
                                Button("Trigger Referring Success") {
                                    ReefReferral.shared.triggerSenderSuccess()
                                }
                            }

                        } else {
                            Text("No info")
                        }

                    }

                    Section(header: Text("Receiver Status")) {
                        if reef.receiverInfo.rewardEligibility != ReefReferral.ReceiverOfferStatus.not_eligible {
                            Text(reef.receiverInfo.rewardEligibility.rawValue )
                            if let receiverOfferCodeURL = reef.receiverInfo.offerCodeURL {
                                Button(receiverOfferCodeURL.absoluteString) {
                                    openURL(receiverOfferCodeURL)
                                }
                            }
                            Button("Trigger Referral Success") {

                                ReefReferral.shared.triggerReceiverSuccess()
                            }
                        } else {
                            Text("Not a referred user")
                        }
                    }

                    Section {
                        Button("Refresh Status") {
                            Task {
                                if let newInfo = try? await ReefReferral.shared.getReferralInfo() {
                                    self.vm.reef = newInfo
                                }
                            }
                        }
                    }

                } else {
                    Text("Connecting to Reef Referral")
                }

            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Reef Referral", displayMode: .large)
            
        }
        .onAppear {
            ReefReferral.shared.delegate = vm
        }

    }
}
