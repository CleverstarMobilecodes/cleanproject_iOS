//
//  MessageDisplayScreen.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/24/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class MessageDisplayScreen  : UIViewController {
    
    @IBOutlet var childUserImageView: UIImageView!
    
    @IBOutlet var childNameLabel: UILabel!
    
    @IBOutlet var newMessageView: UITextView!
    
    override func viewDidLoad() {
        
        self.childNameLabel.text = EarnItChildUser.currentUser.firstName + "'s" + "Task"
        self.newMessageView.text = EarnItChildUser.currentUser.childMessage
        self.newMessageView.isEditable = false
        self.childUserImageView.loadImageUsingCache(withUrl: EarnItChildUser.currentUser.childUserImageUrl)
        
    }
    
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        
        print("closeButtonClicked")
        callUpdateApiForChild(firstName: EarnItChildUser.currentUser.firstName,childEmail: EarnItChildUser.currentUser.email,childPassword: EarnItChildUser.currentUser.password,childAvatar: EarnItChildUser.currentUser.childUserImageUrl!,createDate: EarnItChildUser.currentUser.createDate,childUserId: EarnItChildUser.currentUser.childUserId, childuserAccountId: EarnItChildUser.currentUser.childAccountId,phoneNumber: EarnItChildUser.currentUser.phoneNumber,fcmKey : EarnItChildUser.currentUser.fcmToken, message: nil, success: {
            
            (childUdateInfo) ->() in
            
        }) { (error) -> () in
 
            print("something went wrong")
           // self.view.makeToast("Update Child Failed")
//            let alert = showAlert(title: "Error", message: "Update Child Failed")
//            self.present(alert, animated: true, completion: nil)
//            print(" Set status completed failed")
        }

        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "childDashBoard") as! ChildDashBoard
        self.present(childDashBoard, animated: true, completion: nil)
    }
}
