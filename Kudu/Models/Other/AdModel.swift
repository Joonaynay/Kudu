//
//  AdModel.swift
//  Kudu
//
//  Created by Forrest Buhler on 11/8/21.
//

import Foundation
import UIKit
import GoogleMobileAds

class AdModel: ObservableObject {
    
    static let shared = AdModel()
    
    @Published var interstitial: GADInterstitialAd?
    @Published var lastDate: Date?
    
    init() {
        //Load ad
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: request) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                fatalError(error.localizedDescription)
            } else {
                self.interstitial = ad
            }
        }
    }
}
