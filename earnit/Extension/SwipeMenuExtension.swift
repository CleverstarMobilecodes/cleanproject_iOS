//
//  ParentLandingPageSwipe.swift
//  earnit
//
//  Created by Prakash Chettri on 28/07/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import SlideMenuControllerSwift

protocol SwipeMenuExtension : SlideMenuControllerDelegate{
    
    func rightWillOpen()
    func rightDidOpen()
    func rightWillClose()
    func rightDidClose()
}

extension SwipeMenuExtension {
    
     func rightWillOpen(){
        
        print("right will open")
    }
    
     func rightDidOpen(){
        
        print("right did open")
    }
    
     func rightWillClose(){
        
        print("right will close")
    }
    
     func rightDidClose() {
        
        print("right did close")
    }
    
    
}

extension ParentLandingPage: SwipeMenuExtension {}
extension ParentDashBoard: SwipeMenuExtension {}
//extension ParentApprovalPage: SwipeMenuExtension {}
extension TaskViewController: SwipeMenuExtension {}

