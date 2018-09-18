//
//  TutorialMasterVC.swift
//  EasyD-Day
//
//  Created by 박수성 on 2018. 2. 25..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

class TutorialMasterVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Property
    private let ud = UserDefaults.standard
    
    var pageVC: UIPageViewController!
    
    // 콘텐츠 뷰 컨트롤러에 들어갈 타이틀과 이미지
    var contentImages = ["Page0", "Page1", "Page2", "Page3", "Page4", "Page5", "Page6"]
    
    // MARK: - override / protocol Method
    override func viewWillAppear(_ animated: Bool) {
        self.onPromotionAuthorizationAlert()
    }
    
    override func viewDidLoad() {
        self.setup()
    }
    
    // 현재의 콘텐츠 뷰 컨트롤러보다 앞쪽에 올 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 현재의 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        
        // 현재의 인덱스가 맨 앞이라면 nil을 반환하고 종료
        guard index > 0 else {
            return nil
        }
        
        index -= 1 // 현재의 인덱스에서 하나 뺌
        return self.getContentVC(atIndex: index)
    }
    
    // 현재의 콘텐츠 뷰 컨트롤러보다 뒤쪽에 올 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // 현재의 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        
        index += 1 // 현재의 인덱스에 하나를 더함
        
        // 인덱스는 항상 배열 데이터의 크기보다 작아야 한다.
        guard index < self.contentImages.count else {
            return nil
        }
        
        return self.getContentVC(atIndex: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentImages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    // MARK: - Method
    // 프로모션 동의 알림창
    private func onPromotionAuthorizationAlert() {
        let alert = UIAlertController(title: nil, message: "해당 기기로 이벤트 및 프로모션 등의 정보를 전송하려고 합니다.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "동의", style: .default) { (_) in
            if self.ud.bool(forKey: "setAdPush") != true {
                self.ud.set(true, forKey: "setAdPush")
                self.ud.synchronize()
            }
        })
        
        alert.addAction(UIAlertAction(title: "동의안함", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func setup() {
        let startButton = UIButton(type: UIButton.ButtonType.system)
        startButton.setTitle("시작하기", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 19)
        startButton.frame = CGRect(x: (self.view.frame.width - 66) / 2, y: self.view.frame.height - 55, width: 66, height: 35)
        startButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        self.view.addSubview(startButton)
        
        // 페이지 뷰 컨트롤러 객체 생성
        self.pageVC = self.instanceTutorialVC(name: "PageVC") as? UIPageViewController
        self.pageVC.dataSource = self
        self.pageVC.delegate = self
        
        // 페이지 뷰 컨트롤러의 기본 페이지 지정
        let startContentVC = self.getContentVC(atIndex: 0)! // 최초 노출될 콘텐츠 뷰 컨트롤러
        self.pageVC.setViewControllers([startContentVC], direction: .forward, animated: true)
        
        // 페이지 뷰 컨트롤러의 출력 영역 지정
        self.pageVC.view.frame.origin = CGPoint(x: 0, y: 0)
        self.pageVC.view.frame.size.width = self.view.frame.width
        self.pageVC.view.frame.size.height = self.view.frame.height - 50
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        
        // 페이지 뷰 컨트롤러를 마스터 뷰 컨트롤러의 자식 뷰 컨트롤러로 설정
        self.addChild(self.pageVC) // (1)
        self.view.addSubview(self.pageVC.view) // (2)
        self.pageVC.didMove(toParent: self) // (3)
    }
    
    private func getContentVC(atIndex idx: Int) -> UIViewController? {
        // 인덱스가 데이터 배열 크기 범위를 벗어나면 nil 반환
        guard self.contentImages.count >= idx && self.contentImages.count > 0 else {
            return nil
        }
        
        // "ContentVC"라는 Storyboard ID를 가진 뷰 컨트롤러의 인스턴스를 생성하고 캐스팅한다.
        guard let cvc = self.instanceTutorialVC(name: "ContentsVC") as? TutorialContentsVC else {
            return nil
        }
        // 콘텐츠 뷰 컨트롤러의 내용을 구성
        cvc.imageFile = self.contentImages[idx]
        cvc.pageIndex = idx
        return cvc
    }
    
    // MARK: - @objc Method
    @objc func close(_ sender: Any) {
        self.ud.set(true, forKey: "tutorial")
        self.ud.synchronize()
        
        self.presentingViewController?.dismiss(animated: true)
    }
}
