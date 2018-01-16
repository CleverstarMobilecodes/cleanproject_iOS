//
//  ShowAlertNotificaiton.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/12/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit



/**
 
 User non - specific function
 show alert with option
 
 */

public func showAlertWithOption(title: String,message : String) -> UIAlertController{
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    return alert
    
    
}







/**
 
 User non - specific function
 
 show alert for the user
 
 */


public func showAlert(title: String,message: String) -> UIAlertController {
    

    
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    alert.addAction(UIAlertAction(title: "Ok", style:UIAlertActionStyle.default, handler: nil))
    
    return alert
    
}

