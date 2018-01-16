//
//  DetailView.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/15/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class DetailView : UIView{
    
    @IBOutlet var detailView: UILabel!
    
    @IBOutlet var TaskName: UILabel!
    
    @IBOutlet var Allowance: UILabel!
    
    @IBOutlet var createdDate: UILabel!
    
    @IBOutlet var expiryDate: UILabel!
    
    @IBOutlet var close: UIButton!
    
    class func instanceFromNib() -> UIView {
        
        return UINib(nibName: "DetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    
}
