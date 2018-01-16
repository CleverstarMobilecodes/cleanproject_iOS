//
//  ChangePasswordView.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/5/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordView : UIView {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var currentPassword: UITextField!
    @IBOutlet var newPassword: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    var savePassword: (() -> Void)?
    var closeChangePasswordScreen: (() -> Void)?
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        self.savePassword!()
        
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        
        self.closeChangePasswordScreen!()
    }
    
}
