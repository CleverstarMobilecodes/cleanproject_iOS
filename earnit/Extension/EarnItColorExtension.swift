//
//  EarnItColorExtension.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int){
        
        let newRed = CGFloat(red)/255.0
        let newGreen = CGFloat(green)/255.0
        let newBlue = CGFloat(blue)/255.0
        
        self.init(red: newRed,green: newGreen,blue: newBlue, alpha: 1.0)
    }
    
    convenience init(netHex: Int){
        
        self.init(red:(netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
    }
    
    //EarnIt backgroundColor
    class func EarnItAppBackgroundColor() -> UIColor {
        
        return UIColor.init(netHex: 0x2f2746)
        
    }
    
    //EarnIt EarnItAppTagLineColor
    class func EarnItAppTagLineColor() -> UIColor{
        
        return UIColor.init(netHex: 0xda479c)
    }
    
    class func EarnItAppStandardColor() -> UIColor {
        
        return UIColor.init(netHex: 0x2f2746)
    }
    
    //EarnItAppPinkColor
    class func earnItAppPinkColor() -> UIColor {
        
        return UIColor.init(netHex: 0xda479c )
    }
    
    //EarnItAppCheckInColor
    class func earnItAppCheckInColor() -> UIColor{
        
        return UIColor.init(netHex: 0x07FF05)
    }
    
    //EarnItTaskOverDueColor
    class func earnItTaskOverDueColor() -> UIColor{
        
        return UIColor.init(netHex: 0xda479c)
    }
    
    //EarnItTaskDueColor
    class func earnItTaskDueColor() -> UIColor{
        
        return UIColor.init(netHex: 0xecd92e)
    }
    
    //EarnItTaskCompletedTaskColor
    class func earnItTaskCompletedColor() -> UIColor {
        
        return UIColor.init(netHex: 0x07ff05)
    }
    
    //EarnItTask
    class func earnItTaskNoStatusColor() -> UIColor{
        
        return UIColor.init(netHex: 0xe4e2e2)
    }
    
    
    
}
