//
//  TaskApprovalView.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/28/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class TaskApprovalView : UIView{
    
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var buttonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var dueDateHeightConstraint: NSLayoutConstraint!
    @IBOutlet var descriptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet var taskNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet var commentLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var commentHeightConstraint: NSLayoutConstraint!
    @IBOutlet var taskImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var taskName: UILabel!
    
    @IBOutlet var taskDescription: UITextView!
    //@IBOutlet var taskDescription: UILabel!
    
    @IBOutlet var taskImageView: UIImageView!
    
    @IBOutlet var comments: UITextView!
    @IBOutlet var duedate: UILabel!
    
    //var addTaskForChild: (() -> Void)?
   var declineTask: (() -> Void)?
   var approveTask: (() -> Void)?
   var closeView: (() -> Void)?
   var removeKeyboard: (() -> Void)?
    
    
    class func instanceFromNib() -> UIView {
        
        return UINib(nibName: "TaskApprovalView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    @IBAction func declineButtonClicked(_ sender: Any) {
        
        print("declineButton clicked")
        self.declineTask!()
    }
    
    
    @IBAction func approveButtonClicked(_ sender: Any) {
        
        print("approveButton clicked")
        self.approveTask!()
    }
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        
        self.closeView!()
        
    }
    
    @IBAction func viewGotTapped(_ sender: Any) {
        
        self.removeKeyboard!()
    }
    
}
