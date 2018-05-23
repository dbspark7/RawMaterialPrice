//
//  TutorialContentsVC.swift
//  EasyD-Day
//
//  Created by 박수성 on 2018. 2. 25..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

class TutorialContentsVC: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    var pageIndex: Int!
    var imageFile: String!
    
    override func viewDidLoad() {
        self.bgImageView.image = UIImage(named: self.imageFile)
    }
}
