//
//  MessageView.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/24/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class MessageView : UIView {
    
    
    @IBOutlet var messageToLabel: UILabel!
    @IBOutlet var messageText: UITextView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var callControllerForSendMessage: (() -> Void)?
    var dissmissMe: (() -> Void)?
    
  class func instanceFromNib() -> UIView {
        
        return UINib(nibName: "MessageView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
  }
    

    @IBAction func sendButtonClicked(_ sender: Any) {
        
        self.callControllerForSendMessage!()
        
    }
    
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        
        self.dissmissMe!()
        
    }
    
}
