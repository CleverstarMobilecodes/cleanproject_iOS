//
//  DayHeader.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/11/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class DayHeader : UIView {
    
    var sectionNo = 0
    var isCollapsed = false
    @IBOutlet var dayDetail: UILabel!
    @IBOutlet  var arrowLabel: UIImageView!
    
    class func instanceFromNib() -> UIView {
        
        return UINib(nibName: "DayHeader",bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    
}
