//
//  UIApplication.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 11/11/15.
//  Copyright © 2015 Yuji Hato. All rights reserved.
//
import UIKit

extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        print("returning from UIApplication" )

        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        
        if let slide = viewController as? SlideMenuViewController {
            return topViewController(slide.mainViewController)
        }
        return viewController
    }
}
