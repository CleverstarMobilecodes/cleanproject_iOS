//
//  ChildUserHeaderView.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/6/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class ChildUserHeaderView : UIView {
    
    @IBOutlet var childUserAvatar: UIImageView!
    
    @IBOutlet var checkInLabel: UILabel!
  
    @IBOutlet var childUserName: UILabel!
    
    @IBOutlet var checkInName: UILabel!
    
    @IBOutlet var checkInImage: UIImageView!
    
    @IBOutlet var checkInButton: UIButton!
    
    
     var showActionButton: (() -> Void)?
    
    class func instanceFromNib() -> UIView {
        
        return UINib(nibName: "ChildUserHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    @IBAction func checkInSelected(_ sender: Any) {
        
        print("checkInSelected")
        showActionButton!()
    }
    
    @IBAction func childViewDidTapped(_ sender: UITapGestureRecognizer) {
        
        showActionButton!()
        
    }

}
