//
//  EarnItAppButton.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/5/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func setEarnItAppButton(title: String?,backgroundColor: UIColor) -> UIButton {
        
        let earnItAppButton = UIButton()
        earnItAppButton.backgroundColor = backgroundColor
        earnItAppButton.titleLabel?.textAlignment = .center
        earnItAppButton.layer.cornerRadius = 3
        return earnItAppButton

    }
    
   
    
}

extension UILabel {
    
    
    func setEarnItAppLabel(title: String?) -> UILabel{
        
        let labelForDonotHaveAnAccount = UILabel()
        labelForDonotHaveAnAccount.text = title
        labelForDonotHaveAnAccount.font = FontHelper.EarnItAppLabelFont()
        labelForDonotHaveAnAccount.textColor = UIColor.white
        labelForDonotHaveAnAccount.textAlignment = .center
        return labelForDonotHaveAnAccount
    }
    
 }







