//
//  ReferralSheetView.swift
//  ReefReferralExample
//
//  Created by Piotr Knapczyk on 06/12/2023.
//

import SwiftUI
import ReefReferral

struct ReefReferralSheetView: View {

    @Binding var reef: ReefReferral.ReferralStatus?

    let image: UIImage
    let title: String
    let subtitle: String
    let description: String
    let footnote: String



    public var body: some View {
        if let reef = reef {
            GeometryReader { geometry in
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height / 3)
                    VStack(alignment: .center, spacing: 16) {
                        Text(title)
                            .font(.largeTitle)
                            .foregroundColor(.blue)

                        Text(subtitle)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()

                    Spacer()
                    Button(action: {
                        switch reef.senderStatus.rewardEligibility {
                        case .not_eligible:
                            if let senderLinkURL = reef.senderStatus.linkURL {
                                UIApplication.shared.open(senderLinkURL)
                            } else {
                                print("No referredOfferURL")
                            }
                        case .eligible:
                            if let rewardURL = reef.senderStatus.offerCodeURL{
                                UIApplication.shared.open(rewardURL)
                            } else {
                                print("No rewardURL")
                            }
                        default:
                            break
                        }

                    }) {
                        switch reef.senderStatus.rewardEligibility {
                        case .not_eligible:
                            HStack(spacing: 8) {
                                Text("Invite friends")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.blue)

                        case .eligible:
                            HStack(spacing: 8){
                                Text("Claim Reward!")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Image(systemName: "gift.fill")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.green)
                        case .redeemed:
                            HStack(spacing: 8){
                                Text("Reward Already Claimed")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.gray)
                        }

                    }

                    .cornerRadius(10)

                    Spacer()

                    VStack(spacing:8) {
                        if reef.senderStatus.redeemedCount > 0 {
                            Text("\(reef.senderStatus.redeemedCount) referral successes")
                                .foregroundColor(.green)
                                .bold()
                        }
                    }

                    Spacer()
                    Text(footnote)
                        .font(.footnote)

                }
            }
        } else {
            Text("Reef unavailable")
        }
    }

}
