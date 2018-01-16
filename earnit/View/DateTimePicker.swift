//
//  DateTimePicker.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/22/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit


class DateTimePicker : UIView {
    
    
    var storeDate: (() -> Void)?
    
    var timePicker : UIDatePicker = {
        
        let view =  UIDatePicker()
        view.timeZone = NSTimeZone.local
        view.datePickerMode = .time
        return view
        
    }()
    
    var setSelectedDate: (() -> Void)?
    var closeDatePicker: (() -> Void)?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                
            case 480:
                
                
                self.frame = CGRect(0, 0, 390,200)
                timePicker.frame = CGRect(0, 0, 400, 200)
                
                
                
            case 960:
                
                
                self.frame = CGRect(0, 0, 390,200)
                timePicker.frame = CGRect(0, 0, 400, 200)
                
                
                
            case 1136:
                
                
                self.frame = CGRect(0, 0, 330,200)
                timePicker.frame = CGRect(0, 0, 330, 200)
                
                
                
            case 1334:
                
                self.frame = CGRect(0, 0, 390,200)
                timePicker.frame = CGRect(0, 0, 400, 200)
                
            case 2208:
                
                self.frame = CGRect(0, 0, 390,200)
                timePicker.frame = CGRect(0, 0, 400, 200)
                
            default:
                
                self.frame = CGRect(0, 0, 390,200)
                timePicker.frame = CGRect(0, 0, 400, 200)
                
                print("unknown")
                self.frame = CGRect(0, 0, 390,200)
                timePicker.frame = CGRect(0, 0, 400, 200)
            }
            
        }
        else if  UIDevice().userInterfaceIdiom == .pad {
            
            self.frame = CGRect(0, 0, UIScreen.main.nativeBounds.width/2,500)
            timePicker.frame = CGRect(0, 0, UIScreen.main.nativeBounds.width/2, 500)
        }
        
    
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = " yyyy-MM-dd HH:mm:ss"
        self.timePicker.date =  Date()
        
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))
        
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeButtonPressed))
        
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        
        toolBar.isUserInteractionEnabled = true
        
        
        self.timePicker.datePickerMode = UIDatePickerMode.dateAndTime
        self.addSubview(timePicker)
        self.addSubview(toolBar)
        self.backgroundColor = UIColor.gray

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func datePickerPressed(sender : UIBarButtonItem) {
        
        self.storeDate!()
        
    }
    
    func doneButtonPressed(sender: UIBarButtonItem){
        
        self.setSelectedDate!()
        
    }
    
    func closeButtonPressed(sender: UIBarButtonItem) {
    
        self.closeDatePicker!()
    
    }
}
