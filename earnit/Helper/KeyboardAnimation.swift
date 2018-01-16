//
//  KeyboardAnimation.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/5/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit


/**
 
 User non - specific function
 
 function for re-position View to the normal postion
 
 */

public func rePostionView(currentOffset: CGFloat) -> CGFloat {
    
    var offset = currentOffset
    
    if offset != 0.0 {
        
        UIView.animate(withDuration:0.5, animations: { () -> Void in
            
            offset = 0.0
            
        }, completion: { (completed) -> Void in
            
            offset = 0.0
         
        })
        
    }
    
    return offset
}
