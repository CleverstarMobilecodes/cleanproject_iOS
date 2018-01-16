//
//  TableExtension.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/10/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

public extension UITableView{
    
   
    func registerCellClass(_ cellClass: AnyClass){
        
        let identifier = String(describing: cellClass)
        self.register(cellClass,forCellReuseIdentifier: identifier)
    }
    
}
