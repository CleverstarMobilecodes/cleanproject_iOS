//
//  ChildOptionView.swift
//  earnit
//
//  Created by Lovelini Rawat on 10/6/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class ChildOptionView : UIView {
    
    
    @IBOutlet var firstOption: UIButton!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var secondOption: UIButton!
    @IBOutlet var thirdOption: UIButton!

    
    var doActionForFirstOption: (() -> Void)?
    var doActionForSecondOption: (() -> Void)?
    var doActionForThirdOption: (() -> Void)?
    
    class func instanceFromNib() -> UIView {
        
        return UINib(nibName: "ChildOptionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    
    @IBAction func firstOptionClicked(_ sender: Any) {
        
        self.doActionForFirstOption!()
    }
    
    @IBAction func secondOptionClicked(_ sender: Any) {
        
        self.doActionForSecondOption!()
    }
    
    @IBAction func thirdOptionClicked(_ sender: Any) {
        
        self.doActionForThirdOption!()
        
    }
    
    
}
