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
        @Published var reef: ReefReferral.ReferralStatus?

        func statusUpdated(referralStatus: ReefReferral.ReferralStatus) {
            self.reef = referralStatus
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
                        if let linkURL = reef.senderStatus.linkURL {

                            Button("Set custom ID") {
                                ReefReferral.shared.setUserId("custom_id_test a as @@.com")
                            }

                            Button(linkURL.absoluteString) {
                                openURL(linkURL)
                            }

                            Text("\(reef.senderStatus.redeemedCount ) redeemed")
                            Text("\(reef.senderStatus.rewardEligibility.rawValue )")

                            if let rewardURL = reef.senderStatus.offerCodeURL {
                                Button(rewardURL.absoluteString) {
                                    openURL(rewardURL)
                                }
                            }
                            if reef.senderStatus.rewardEligibility != .redeemed {
                                Button("Trigger Referring Success") {
                                    ReefReferral.shared.triggerSenderSuccess()
                                }
                            }

                        } else {
                            Text("No info")
                        }

                    }

                    Section(header: Text("Receiver Status")) {
                        if reef.receiverStatus.rewardEligibility != ReefReferral.ReceiverOfferStatus.not_eligible {
                            Text(reef.receiverStatus.rewardEligibility.rawValue )
                            if let receiverOfferCodeURL = reef.receiverStatus.offerCodeURL {
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
                                if let newInfo = try? await ReefReferral.shared.getReferralStatus() {
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
