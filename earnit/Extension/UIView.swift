//
//  UIView.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/10/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {

        let className = String(describing: viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
        
    }
    
    class func loadNib() -> Self{
        
        return loadNib(self)
    }
}

