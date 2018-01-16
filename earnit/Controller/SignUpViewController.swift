//
//  SignUpViewController.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/3/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class SignUpViewController : UIViewController {
    
    @IBOutlet var email: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var confirmPassword: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    
    var currentKeyboardOffset : CGFloat = 0.0
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var isPasswordMatchesWithConfirmPassword = Bool()
    
    var isEmailValid = Bool()
    
    override func viewDidLoad() {
        
        self.requestObserver()
        
        self.creatLeftPadding(textField: email)
        self.creatLeftPadding(textField: password)
        self.creatLeftPadding(textField: confirmPassword)

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.email.text = ""
        self.password.text = ""
    }
    
    @IBAction func emailDidEndEditing(_ sender: Any) {
        
        if (email.text?.isEmail)! {
            
            self.isEmailValid = true
        }else {
            
            self.isEmailValid = false
        
        }
        
    }

    @IBAction func passwordDidEndEditing(_ sender: UITextField) {
        
        
    }
    
    @IBAction func confirmPasswordDidEndEditing(_ sender: UITextField) {
        
        if self.password.text == self.confirmPassword.text {
            
            self.isPasswordMatchesWithConfirmPassword = true
            
        }else {
            
            self.isPasswordMatchesWithConfirmPassword = false
            
        }
        
    }
    
    
    @IBAction func goBackToLogin(_ sender: Any) {
        
        print("go back to Login")
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func CheckValidityAndCallSignUpApi(_ sender: Any) {
        
        self.view.endEditing(true)
        print("Inside CheckValidityAndCallSignUpApi")
        if (self.email.text?.characters.count)! == 0 || (self.password.text?.characters.count)! == 0 || (self.confirmPassword.text?.characters.count)! == 0  {
            
//            let alert = showAlert(title: "", message: "Please complete all the fields")
//            self.present(alert, animated: true, completion: nil)
            self.view.makeToast("Please complete all the fields")
            
        }else if self.isEmailValid == false{
            
            self.view.makeToast("Invalid Email")
            //let alert = showAlert(title: "", message: "Invalid Email")
            self.password.text = ""
            self.confirmPassword.text = ""
            //self.present(alert, animated: true, completion: nil)
            
        }else if self.isPasswordMatchesWithConfirmPassword == false{
            
            self.view.makeToast("Confirm password doesn't match with password")
            //let alert = showAlert(title: "", message: "Confirm password doesn't match with password")
            self.password.text = ""
            self.confirmPassword.text = ""
            //self.present(alert, animated: true, completion: nil)

        }else {
            
            self.showLoadingView()
            callSignUpApiForParent(email: self.email.text!, password: self.password.text!, success: {
                
                (responseJSON,errorCode) ->() in
                
                self.hideLoadingView()
                
                if (errorCode == "9000"){
                    
                  self.view.makeToast("A user with this email already exist")
                  //let alert = showAlert(title: "", message: "A user with this email already exist")
                  //self.present(alert, animated: true, completion: nil)
                  self.email.text = ""
                  self.password.text = ""
                  self.confirmPassword.text = ""
                    
                }else {
                    
                    
                    let keychain = KeychainSwift()
                    
                    keychain.set(responseJSON["email"].stringValue, forKey: "email")
                    keychain.set(responseJSON["password"].stringValue, forKey: "password")
                    keychain.set(true, forKey: "isActiveUser")
                    keychain.set(false, forKey: "isProfileUpdated")
             

                    let fcmToken : String? = keychain.get("token")
                    EarnItAccount.currentUser.setAttribute(json: responseJSON)
                    
                    
                    if responseJSON["fcmToken"].stringValue != keychain.get("token") || responseJSON["fcmToken"].stringValue == nil || responseJSON["fcmToken"].stringValue == ""{
                        
                        print("fcm token is null")
                        callUpdateProfileApiForParentt(firstName: EarnItAccount.currentUser.firstName, lastName: EarnItAccount.currentUser.lastName, phoneNumber: EarnItAccount.currentUser.phoneNumber!, updatedPassword: EarnItAccount.currentUser.password,imageUrl: EarnItAccount.currentUser.avatar!,fcmKey : fcmToken,success: {
                            
                            (earnItParentInfo) ->() in
                            
                            EarnItAccount.currentUser.fcmToken = fcmToken
                            
                        }) { (error) -> () in
                            
                            let alert = showAlert(title: "Error", message: "Update Profile Failed")
                            self.present(alert, animated: true, completion: nil)
                            print(" Set status completed failed")
                        }
                    }
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let profilePage  = storyBoard.instantiateViewController(withIdentifier: "FirstTimeLoginProfileUpdateScreen") as! FirstTimeLoginProfileScreen
                 //   profilePage.shouldGoBackToLandingPage = true
                    
                   // let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                    
                   // let slideMenuController  = SlideMenuViewController(mainViewController: profilePage, leftMenuViewController: optionViewController)
                    
                 //   slideMenuController.automaticallyAdjustsScrollViewInsets = true
                    //slideMenuController.delegate = profilePage
                    
                    self.present(profilePage, animated:false, completion:nil)
                
                }
         
                
            }) { (error) -> () in
                
                self.view.makeToast("SignUp failed")
//                let alert = showAlert(title: "Error", message: "SignUp Failed")
//                self.present(alert, animated: true, completion: nil)
                
            }

        }
        
    }
    
 
    //ovrride
    func dismissScreen(alert: UIAlertAction) {
        
       self.dismiss(animated: true, completion: nil)
    
    }
    
    
    /**
     Add observer to the View
     
     :param: nil
     */
    
    func requestObserver(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide  , object: nil)
    }
    
    
      /**
     To assign Left Padding for Textfield
     
     :param: UITextField
     */
    
    func creatLeftPadding(textField:UITextField) {
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.size.height))
        textField.leftView = leftPadding
        textField.leftViewMode = UITextFieldViewMode.always
        
    }
    

    
    
    /**
     Responds to keyboard showing and adjusts the scrollview.
     
     :param: notification
     Type - NSNotification
     */
    
    func keyboardWillShow(_ notification:NSNotification){
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
    }
    
//    func keyboardWillShow(_ notification:NSNotification){
//        
//        let info = notification.userInfo!
//        let keyboardHeight: CGFloat = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
//        let keyboardYValue = self.view.frame.height - keyboardHeight
//        
//        if UIDevice().userInterfaceIdiom == .phone {
//            
//            switch UIScreen.main.nativeBounds.height {
//                
//            case 2208:
//                
//                if email.isFirstResponder {
//                    
//                    let emailYValue = self.email.frame.size.height + self.email.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (emailYValue ) > keyboardYValue - 100 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - emailYValue + 70
//                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            }, completion: { (completed) -> Void in
//                                
//                                
//                            })
//                            
//                        }
//                        
//                    }
//                    
//                }else if password.isFirstResponder{
//                    
//                    let passwordYValue = self.password.frame.size.height + self.password.frame.origin.y
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if passwordYValue > (keyboardYValue + 10.0) {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - passwordYValue + 70
//                            UIView.animate(withDuration: 0.5, animations: {() -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            })
//                        }
//                    }
//                    
//                }else if confirmPassword.isFirstResponder{
//                    
//                    let confirmPasswordYValue = self.confirmPassword.frame.size.height + self.confirmPassword.frame.origin.y
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if confirmPasswordYValue > (keyboardYValue) + 40 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - confirmPasswordYValue + 70
//                            UIView.animate(withDuration: 0.5, animations: {() -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            })
//                        }
//                    }
//                 
//                }
//
//            default:
//                
//                if email.isFirstResponder {
//                    
//                    let emailYValue = self.email.frame.size.height + self.email.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (emailYValue) > keyboardYValue  {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - emailYValue + 170
//                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            }, completion: { (completed) -> Void in
//                                
//                                
//                            })
//                            
//                        }
//                        
//                    }
//                    
//                }else if password.isFirstResponder{
//                    
//                    let passwordYValue = self.password.frame.size.height + self.password.frame.origin.y
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if passwordYValue > (keyboardYValue)  {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - passwordYValue + 120
//                            UIView.animate(withDuration: 0.5, animations: {() -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            })
//                        }
//                    }
//                    
//                }else if confirmPassword.isFirstResponder{
//                    
//                    let confirmPasswordYValue = self.confirmPassword.frame.size.height + self.confirmPassword.frame.origin.y
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if confirmPasswordYValue > (keyboardYValue) + 40 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - confirmPasswordYValue + 200
//                            UIView.animate(withDuration: 0.5, animations: {() -> Void in
//                                self.view.frame.origin.y -= self.currentKeyboardOffset
//                                
//                            })
//                        }
//                    }
//                    
//                }
//                
//            }
//            
//        }
//    
//    }

    
    
    
    /**
     Responds to keyboard hiding and adjusts the View.
     
     :param: notification
     Type - NSNotification
     */
    
    func keyboardWillHide(_ notification:NSNotification){
        
        print("Keyboard will hide...")
//        let keyboardOffset : CGFloat = rePostionView(currentOffset: self.currentKeyboardOffset)
//        self.view.frame.origin.y = keyboardOffset
//        self.currentKeyboardOffset = keyboardOffset
        
         scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func showLoadingView(){
        
        self.scrollView.alpha = 0.7
        self.scrollView.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        
    }
    
    
    func hideLoadingView(){
        
        self.scrollView.alpha = 1
        self.scrollView.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func viewGotTapped(_ sender: Any) {
        
        print("View got tapped")
        self.view.endEditing(true)
    }

    
   
}
        

