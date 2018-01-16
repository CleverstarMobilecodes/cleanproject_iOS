//
//  ChildListHeader.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/17/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class ChildListHeader : UIView {
    
    class func instanceFromNib() -> UIView {
        
        return UINib(nibName: "ChildListHeader",bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    
}
