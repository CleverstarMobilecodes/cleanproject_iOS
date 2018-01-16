//
//  OptionCell.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/10/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

open class OptionCell : UITableViewCell {
    
    class var identifier: String{ return String(describing: self) }
    
    public required init?(coder aDecoder: NSCoder){
        
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    open class func height() -> CGFloat{
        
        return 48
    }
    
    open override func awakeFromNib() {
        
    }
    
    
    open func setup(){
        
        
    }
    
    open func setData(_ data: Any){
        self.backgroundColor = UIColor.EarnItAppBackgroundColor()
        self.textLabel?.font = FontHelper.EarnItAppLabelFont()
        self.textLabel?.textColor = UIColor.white
        if let optionText = data as? String{
            
            self.textLabel?.text = optionText
        }
        
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted{
            
            self.alpha = 0.4
        }else {
            
            self.alpha = 1.0
        }
    }

}
