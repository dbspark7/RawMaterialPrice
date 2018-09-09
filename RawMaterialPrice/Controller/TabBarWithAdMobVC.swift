//
//  TabBarWithAdMobVC.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 2. 10..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit
import GoogleMobileAds

class TabBarWithAdMobVC: UITabBarController, GADBannerViewDelegate {
    
    // MARK: - Property
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var bannerView: GADBannerView! // 구글 애드몹 프로퍼티
    private var bannerFrameView: UIView?
    
    // MARK: - override Method
    override func viewDidLoad() {
        if self.appDelegate.admobIsOn == true {
            self.bannerFrameView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 60, width: self.view.frame.width, height: 60))
            self.bannerFrameView?.backgroundColor = UIColor.black
            self.view.addSubview(bannerFrameView!)
            
            // In this case, we instantiate the banner with desired ad size.
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            
            //adViewDidReceiveAd(bannerView)
            
            bannerView.adUnitID = IDKey.AD_UNIT_ID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
    }
    
    override func viewWillLayoutSubviews() {
        if self.appDelegate.admobIsOn == true {
            self.tabBar.frame = CGRect(x: 0, y: self.view.frame.height - 110, width: self.tabBar.frame.width, height: 50)
        }
    }
    
    // MARK: - 구글 애드몹
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func adViewDidReceiveAd(_ bannerView : GADBannerView) {
        
        // 위와 같이 제약 조건을보고 추가하는 배너를 추가합니다.
        addBannerViewToView(bannerView)
        
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        
        bannerView.translatesAutoresizingMaskIntoConstraints = true
        bannerView.frame = CGRect(x: (self.view.frame.width - bannerView.frame.width) / 2, y: 10, width: bannerView.frame.width, height: bannerView.frame.height)
        self.bannerFrameView?.addSubview(bannerView)
    }
}
