

//
//  OptionView.swift
//  earnit
//
//  Created by Lovelini Rawat on 9/21/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class OptionView : UIView {
    
   
    @IBOutlet var firstOption: UIButton!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var secondOption: UIButton!
    @IBOutlet var thirdOption: UIButton!
    @IBOutlet var forthOption: UIButton!
    @IBOutlet var fifthOption: UIButton!
    @IBOutlet var sixthOption: UIButton!
    
    var doActionForFirstOption: (() -> Void)?
    var doActionForSecondOption: (() -> Void)?
    var doActionForThirdOption: (() -> Void)?
    var doActionForFourthOption: (() -> Void)?
    var doActionForFifthOption: (() -> Void)?
    var doActionForSixthOption: (() -> Void)?
    
    class func instanceFromNib() -> UIView {
        
        return UINib(nibName: "OptionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
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
    @IBAction func forthOptionClicked(_ sender: Any) {
        
        self.doActionForFourthOption!()
    }
    @IBAction func fifthOptionClicked(_ sender: Any) {
        
        self.doActionForFifthOption!()
    }
    
    @IBAction func sixthOptionClicked(_ sender: Any) {
        
        self.doActionForSixthOption!()
    }
    
 
    
}
