//
//  SlideMenuViewController.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/8/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class SlideMenuViewController: SlideMenuController {
    
    override func track(_ trackAction: TrackAction) {
        switch trackAction {
        case .leftTapOpen:
            print("TrackAction: left tap open.")
        case .leftTapClose:
            print("TrackAction: left tap close.")
        case .leftFlickOpen:
            print("TrackAction: left flick open.")
        case .leftFlickClose:
            print("TrackAction: left flick close.")
        case .rightTapOpen:
            print("TrackAction: right tap open.")
        case .rightTapClose:
            print("TrackAction: right tap close.")
        case .rightFlickOpen:
            print("TrackAction: right flick open.")
        case .rightFlickClose:
            print("TrackAction: right flick close.")
        }
    }

}
