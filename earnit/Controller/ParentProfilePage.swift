//
//  ParentProfilePage.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/5/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift
import AssetsLibrary
import AVFoundation
import AWSS3
import ALCameraViewController


class ParentProfilePage : UIViewController,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate, UINavigationControllerDelegate,UITextFieldDelegate{
    
    
    
    @IBOutlet var welcomeLabel: UILabel!
    
    @IBOutlet var childTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var contactNumber: UITextField!
    var changePasswordView = ChangePasswordView()
    var currentKeyboardOffset : CGFloat = 0.0
    //layout contraint for the detailView box
    var constX:NSLayoutConstraint?
    @IBOutlet var bottomView: UIView!
    @IBOutlet var childUserTable: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var countryCodeField: UITextField!
    @IBOutlet var countryNameLabel: UILabel!
    @IBOutlet var countryCodeLabel: UILabel!
    
    //layout contraint for the detailView box
    var constY:NSLayoutConstraint?
    
    var newPassword = String()
    
    var shouldGoBackToLandingPage = Bool()
    
    //isImageChanged
    var isImageChanged: Bool?
    
    var userImage: UIImage!

    //imagePicker
    var imagePicker : UIImagePickerController!
    
    var earnItChildUsers = [EarnItChildUser]()
    var userImageUrl : String?
    let keychain = KeychainSwift()
    var didShownImagePicker = false
    var activeField:UITextField?
    var counrtyPicker = UIPickerView()
    var countryList : [Dictionary<String, String>]?
    var isCountryPickerShown = false
    var selectedCountryDetails : [String:String]!
    
    override func viewDidLoad() {
        
        self.setImagePicker()
        self.isImageChanged = false
        self.childUserTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.childUserTable.tableFooterView = UIView()
        self.scrollView.contentSize = CGSize(290, 1000)
        userImageView.loadImageUsingCache(withUrl: EarnItAccount.currentUser.avatar!)
        
        
        self.creatLeftPadding(textField: firstName)
        self.creatLeftPadding(textField: lastName)
        self.creatLeftPadding(textField: email)
        self.creatLeftPadding(textField: contactNumber)
        self.addButtonsOnKeyboard()

        self.readJson()
        selectedCountryDetails = countryList![0]
        self.countryCodeField.inputView = counrtyPicker
        
        counrtyPicker.dataSource = self
        counrtyPicker.delegate = self
//        self.countryNameLabel.text = selectedCountryDetails["code"]
//        self.countryCodeLabel.text = selectedCountryDetails["dial_code"]
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("Inside viewDidAppear")
       
        _ = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.fetchParentUserDetailFromBackground), userInfo: nil, repeats: true)
        
        //self.bottomView.frame.origin.y =  self.childUserTable.frame.origin.y
        if self.didShownImagePicker == false{
            
            self.isImageChanged = false
            self.earnItChildUsers = EarnItAccount.currentUser.earnItChildUsers
            self.prepareView()
        }
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
    
    func prepareView(){
    
        print("Inside prepareView")
        self.newPassword = (keychain.get("password")!)
        self.userImageUrl = EarnItAccount.currentUser.avatar?.replacingOccurrences(of: "\"", with:  " ")
        if EarnItAccount.currentUser.firstName == " "{
            
            EarnItAccount.currentUser.firstName = ""
        }
        self.firstName.text = EarnItAccount.currentUser.firstName
        self.lastName.text = EarnItAccount.currentUser.lastName
        self.email.text = EarnItAccount.currentUser.email
        self.contactNumber.text = getPhoneNumber()
        self.addTapGestureForChildRow()
        self.requestObserver()
        
        self.setCountryCode()
        print("self.earnItChildUsers count--- \(self.earnItChildUsers.count)")
        print("EarnItAccount.currentUser.earnItChildUsers in profile -- \(EarnItAccount.currentUser.earnItChildUsers.count)")
        self.childUserTable.reloadData()
        self.childTableHeightConstraint.constant = self.childUserTable.contentSize.height
        //self.welcomeLabel.text = "Welcome" + EarnItAccount.currentUser.firstName
    }
    

    func getPhoneNumber() -> String {
        
        let phoneNo = EarnItAccount.currentUser.phoneNumber as! String
        let last10 = String(describing: phoneNo.suffix(10) )
        return last10
    }
    
    func getCountryCode() -> String {
        
        let phoneNo = EarnItAccount.currentUser.phoneNumber as! String
        
        if phoneNo.characters.count >= 10 {
            let endIndex = phoneNo.index(phoneNo.endIndex, offsetBy: -10)
            let truncated = phoneNo.substring(to: endIndex)
            let countryCode = String(describing: truncated)
            return countryCode
        }
        
        return countryList![0]["dial_code"]!
    }
    
    func setCountryCode()  {
        
        let CC = self.getCountryCode()
        
        for countryDetail in countryList! {
            if countryDetail["dial_code"] == CC {
                
                self.selectedCountryDetails = countryDetail
                break
            }
        }
        
        self.countryNameLabel.text = selectedCountryDetails["code"]
        self.countryCodeLabel.text = selectedCountryDetails["dial_code"]
    }
    
    func setImagePicker(){
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        
    }
    

    func addTapGestureForChildRow(){
    
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(childDidTap))
        tapRecognizer.delegate = self
        self.childUserTable.addGestureRecognizer(tapRecognizer)
        
    }
    
    func childDidTap(recognizer: UISwipeGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.ended {
            let tapLocation = recognizer.location(in: self.childUserTable)
            if let tapIndexPath = self.childUserTable.indexPathForRow(at: tapLocation) {
                if let tapCell = self.childUserTable.cellForRow(at: tapIndexPath) {
                    
                    print("child user got tapped")
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                    let addChildPage = storyBoard.instantiateViewController(withIdentifier: "AddChildPage") as! AddChildPage
                    addChildPage.earnItChildUser = self.earnItChildUsers[tapIndexPath.row]
                    addChildPage.isInEditingMode = true
                    self.didShownImagePicker = false
                    
//                    let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
//
//                    let slideMenuController  = SlideMenuViewController(mainViewController: addChildPage, leftMenuViewController: optionViewController)
//
//                    slideMenuController.automaticallyAdjustsScrollViewInsets = true
                    self.present(addChildPage, animated:false, completion:nil)
                   // slideMenuController.delegate = addChildPage as! SlideMenuControllerDelegate

                    
                }
            }
        }
    }

    
    /**
     Add observer to the View
     
     :param: nil
     */
    
    func requestObserver(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParentProfilePage.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentProfilePage.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide  , object: nil)
        
    }
    
    
    
    /**
     Responds to keyboard showing and adjusts the scrollview.
     
     :param: notification
     Type - NSNotification
     */
    
//    func keyboardWillShow(_ notification:NSNotification){
//        
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
//                if firstName.isFirstResponder {
//                    
//                    let firstNameYValue = self.firstName.frame.size.height + self.firstName.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (firstNameYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - firstNameYValue + 230
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
//                
//                }else if lastName.isFirstResponder {
//                    
//                    let lastNameYValue = self.lastName.frame.size.height + self.lastName.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (lastNameYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - lastNameYValue + 230
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
//                }else  if contactNumber.isFirstResponder {
//                    
//                    let contactNumberYValue = self.contactNumber.frame.size.height + self.contactNumber.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (contactNumberYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - contactNumberYValue + 230
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
//                }
//                
//                
//            default:
//                
//                if firstName.isFirstResponder {
//                    
//                    let firstNameYValue = self.firstName.frame.size.height + self.firstName.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (firstNameYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - firstNameYValue + 230
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
//                    
//                }else if lastName.isFirstResponder {
//                    
//                    let lastNameYValue = self.lastName.frame.size.height + self.lastName.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (lastNameYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - lastNameYValue + 230
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
//                }else  if contactNumber.isFirstResponder {
//                    
//                    let contactNumberYValue = self.contactNumber.frame.size.height + self.contactNumber.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (contactNumberYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - contactNumberYValue + 230
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
//                }
//                
//            }
//    
//        }
//    }
    
    
    
    
    
    /**
     Responds to keyboard hiding and adjusts the View.
     
     :param: notification
     Type - NSNotification
     */
    
//    func keyboardWillHide(_ notification:NSNotification){
//        
//        
//        let keyboardOffset : CGFloat = rePostionView(currentOffset: self.currentKeyboardOffset)
//        self.view.frame.origin.y = keyboardOffset
//        self.currentKeyboardOffset = keyboardOffset
//        
//    }
    

    func keyboardWillShow(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height+100, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            
            if (!aRect.contains(activeField.frame.origin)){
                
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        // self.scrollView.isScrollEnabled = false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == countryCodeField {
            
            
            let CC = self.selectedCountryDetails["dial_code"]
            
            var i = 0
            
            for countryDetail in countryList! {
                if countryDetail["dial_code"] == CC {
                    counrtyPicker.selectRow(i, inComponent: 0, animated: false)
                    return true
                }
                
                i = i+1
            }
            counrtyPicker.selectRow(0, inComponent: 0, animated: false)
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField==firstName || textField==lastName) {
            
            let characterSet = CharacterSet.letters
            if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                return false
            }
        }
            
        else if (textField==contactNumber) {
            
            let charsLimit = 10
            let startingLength = textField.text?.characters.count ?? 0
            let lengthToAdd = string.characters.count
            let lengthToReplace =  range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            return newLength <= charsLimit
        }
        
        return true
    }

    
  
    @IBAction func openChangePasswordDialog(_ sender: Any) {
        
        
    }
    
    @IBAction func goToAddChildUserPage(_ sender: Any) {
        
        print("add child clicked ")
        
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let addChildPage = storyBoard.instantiateViewController(withIdentifier: "AddChildPage") as! AddChildPage
        self.didShownImagePicker = false
       
        
        let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
        
        let slideMenuController  = SlideMenuViewController(mainViewController: addChildPage, leftMenuViewController: optionViewController)
        
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        self.present(slideMenuController, animated:false, completion:nil)

    }
    
    @IBAction func goBack(_ sender: UIButton) {
        
        if self.shouldGoBackToLandingPage == true{
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
            
            let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
            
            let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
            
            slideMenuController.automaticallyAdjustsScrollViewInsets = true
            slideMenuController.delegate = parentLandingPage
            
            self.present(slideMenuController, animated:false, completion:nil)
            
        }else {
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    

    @IBAction func UpdateButtonClicked(_ sender: Any) {
 
        if (self.firstName.text?.characters.count == 0 && self.contactNumber.text?.characters.count == 0 && self.lastName.text?.characters.count == 0){
            
            self.view.makeToast("Please complete all fields")
            
        }
        
        
        if (self.firstName.text?.characters.count == 0 || self.contactNumber.text?.characters.count == 0 || self.lastName.text?.characters.count == 0){
            
            var errorFields = "\(self.firstName.text?.characters.count == 0 ? "First name and":"")\(self.lastName.text?.characters.count == 0 ? " Last name and":"")\(self.contactNumber.text?.characters.count == 0 ? " Phone":"")"
            
            let last3 = errorFields.substring(from:errorFields.index(errorFields.endIndex, offsetBy: -3))
            
            
            if last3 == "and" {
                errorFields = errorFields.substring(to: errorFields.index(errorFields.endIndex, offsetBy: -3))
            }
            
            self.view.makeToast("Please complete \(errorFields) field")
            
        }
            
        else if  (self.contactNumber.text?.characters.count)! < 10 {
            
            self.view.makeToast("Please enter valid phone number")
        }
            
            
        else {
        
          
            var contactNumber = String()
            if (self.contactNumber.text?.characters.count)! > 0{
                
                 contactNumber = "\(self.countryCodeLabel.text!)\(self.contactNumber.text!)"
              }else {
       
                contactNumber = ""
            }
                
            if self.isImageChanged == true {
       
             print("User has picked Image from device")
                
                 DispatchQueue.global().async {
     
                        self.prepareUserImageForUpload()
    
                         DispatchQueue.main.async {
            
                           print("Done with image Upload and updated to backend!")
                         }
                    }
                
            }
        
            self.showLoadingView()
            let keychain = KeychainSwift()
            let fcmToken : String? = keychain.get("token")
            callUpdateProfileApiForParentt(firstName: self.firstName.text!, lastName: self.lastName.text!, phoneNumber: contactNumber, updatedPassword: EarnItAccount.currentUser.password,imageUrl: self.userImageUrl!, fcmKey: fcmToken,success: {
            
            (earnItTask) ->() in
                
                let keychain = KeychainSwift()
                guard  let _ = keychain.get("email") else  {
                    print(" /n Unable to fetch user credentials from keychain \n")
                    return
                }
                let email : String = (keychain.get("email")!)
                let password : String = (keychain.get("password")!)
                
                checkUserAuthentication(email: email, password: password, success: {
                    
                    (responseJSON) ->() in
                    
                    self.view.makeToast("Update successful")
                    self.dismissScreen()
//                    let alert = showAlertWithOption(title: "", message: "Update successful")
//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreen))
//                    self.present(alert, animated: true, completion: nil)
          
                        EarnItAccount.currentUser.setAttribute(json: responseJSON)
                        keychain.set(String(EarnItAccount.currentUser.accountId), forKey: "userId")
                        self.hideLoadingView()
                        // success(true)
                    
                    
                }) { (error) -> () in
                    
                    
                    self.dismissScreenToLogin()
                    
//                    let alert = showAlertWithOption(title: "Authentication failed", message: "please login again")
//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreenToLogin))
//                    self.present(alert, animated: true, completion: nil)
                    
                }

            
        }) { (error) -> () in
            
            self.view.makeToast("Update Profile Failed")
//            let alert = showAlert(title: "Error", message: "Update Profile Failed")
//            self.present(alert, animated: true, completion: nil)
//            print(" Set status completed failed")
          }
            
          }
        

    }
    
    
    //ovrride
    func dismissScreen(){
        
        //self.dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
        
        let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
        
        let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
        
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = parentLandingPage
        
        self.present(slideMenuController, animated:false, completion:nil)
    }
    @IBAction func viewDidTapped(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func changePasswordButtonClicked(_ sender: Any) {
    
        changePasswordView = (Bundle.main.loadNibNamed("ChangePasswordView", owner: self, options: nil)?[0] as? ChangePasswordView)!
        let changePasswordContainer = UIView()
        changePasswordContainer.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        changePasswordContainer.backgroundColor = UIColor.clear
        self.creatLeftPadding(textField: self.changePasswordView.currentPassword)
        self.creatLeftPadding(textField: self.changePasswordView.newPassword)
        self.creatLeftPadding(textField: self.changePasswordView.confirmPassword)

        changePasswordView.center = changePasswordContainer.center
        changePasswordContainer.addSubview(changePasswordView)
        self.view.addSubview(changePasswordContainer)
        
        changePasswordView.closeChangePasswordScreen = {
            
            self.changePasswordView.removeFromSuperview()
            changePasswordContainer.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }
        
        changePasswordView.savePassword = {
            
            let keychain = KeychainSwift()
            let password : String = keychain.get("password") as! String
            
            if (self.changePasswordView.currentPassword.text!.characters.count == 0) || (self.changePasswordView.newPassword.text?.characters.count == 0) || (self.changePasswordView.confirmPassword.text?.characters.count) == 0{
                
                self.view.makeToast("Please complete all the fields")
//                let alert = showAlert(title: "", message: "Please complete all the fields")
//                self.present(alert, animated: true, completion: nil)
                
            }else if self.changePasswordView.currentPassword.text != password {
                
                  self.view.makeToast("Entered current password is incorrect")
//                let alert = showAlert(title: "", message: "Entered current password is incorrect")
//                self.present(alert, animated: true, completion: nil)
                
            }else if self.changePasswordView.newPassword.text != self.changePasswordView.confirmPassword.text  {
                
                self.view.makeToast("New password doesn't match with confirm password!")
//                let alert = showAlert(title: "", message: "New password doesn't match with confirm password!")
//                self.present(alert, animated: true, completion: nil)
                
            }else {
                
                self.showLoadingView()
                self.changePasswordView.activityIndicator.startAnimating()
                self.newPassword = self.changePasswordView.confirmPassword.text!
                let keychain = KeychainSwift()
                let fcmToken : String? = keychain.get("token")
                
                callUpdateProfileApiForParentt(firstName: EarnItAccount.currentUser.firstName, lastName: EarnItAccount.currentUser.lastName, phoneNumber: EarnItAccount.currentUser.phoneNumber!, updatedPassword: self.newPassword,imageUrl: EarnItAccount.currentUser.avatar!,fcmKey: fcmToken, success: {
                    
                    (earnItTask) ->() in
                    
                    self.changePasswordView.removeFromSuperview()
                    self.view.isUserInteractionEnabled = true
                    self.view.makeToast("Password saved successfully")
//                    let alert = showAlert(title: "", message: "Password saved successfully")
//                    self.present(alert, animated: true, completion: nil)
                    self.hideLoadingView()
                    self.changePasswordView.activityIndicator.stopAnimating()
                    self.changePasswordView.removeFromSuperview()
                    changePasswordContainer.removeFromSuperview()
          
                }) { (error) -> () in
                    
                    self.view.makeToast("Save password failed")
//                    let alert = showAlert(title: "Error", message: "Update Profile Failed")
//                    self.present(alert, animated: true, completion: nil)
//                    print(" Set status completed failed")
                }
                


            }
        
        }
        
        var dView:[String:UIView] = [:]
        dView["ChangePasswordView"] = changePasswordView
        
        let h_Pin = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(36)-[ChangePasswordView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0) , metrics: nil, views: dView)
        self.view.addConstraints(h_Pin)
        
        let v_Pin = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(36)-[ChangePasswordView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dView)
        self.view.addConstraints(v_Pin)
        
        constY = NSLayoutConstraint(item: changePasswordView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        self.view.addConstraint(constY!)
        
        
        constX = NSLayoutConstraint(item: changePasswordView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        self.view.addConstraint(constX!)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.50, options: UIViewAnimationOptions.layoutSubviews, animations: { () -> Void in
            self.changePasswordView.alpha = 1
            
            
            self.view.layoutIfNeeded()
        }) { (value:Bool) -> Void in
            
        }

    }
  
    @IBAction func changePassWordEditButtuonPressed(_ sender: Any) {
        self.changePasswordButtonClicked(sender)
    }
    
    @IBAction func userImageViewGotTapped(_ sender: UITapGestureRecognizer) {

        print("ImageView got tapped")
        
        var libraryEnabled: Bool = true
        var croppingEnabled: Bool = true
        var allowResizing: Bool = true
        var allowMoving: Bool = true
        var minimumSize: CGSize = CGSize(width: 200, height: 200)
        
        var croppingParameters: CroppingParameters {
            return CroppingParameters(isEnabled: croppingEnabled, allowResizing: allowResizing, allowMoving: allowMoving, minimumSize: minimumSize)
        }
        
        
        
        
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: libraryEnabled) { [weak self] image, asset in
            
            if image != nil
            {
                let resizedImage = self?.resizeImage(image!, newWidth: 300)
                self?.userImage = resizedImage
                self?.userImageView.image = resizedImage
                self?.isImageChanged = true
                self?.didShownImagePicker = true
            }
            self?.dismiss(animated: true, completion: nil)
            
        }
        present(cameraViewController, animated: true, completion: nil)
        
        
        
        return
        

        
        
//        let actionSheet = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
//            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) -> Void in
//
//                if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized
//                {
//                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//                    self.present(self.imagePicker, animated: true, completion: nil)
//
//                }
//                else
//                {
//                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
//                        if granted == true
//                        {
//                            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//                            self.present(self.imagePicker, animated: true, completion: nil)
//
//                        }
//                        else
//                        {
//
//                            self.view.makeToast("You don't have permission to access camera")
////                            let alert = showAlert(title: "Not allowed", message: "You don't have permission to access camera")
////
////                            self.present(alert, animated: true, completion: nil)
//
//                        }
//                    });
//                }
//
//
//            }
//            actionSheet.addAction(cameraAction)
//        }
//
//        let albumAction = UIAlertAction(title: "Photo Library", style: .default) { (action) -> Void in
//            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }
//
//        actionSheet.addAction(albumAction)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        actionSheet.addAction(cancelAction)
//        actionSheet.popoverPresentationController?.sourceView = self.view
//
//        var ActionSheetFrame = userImageView.frame
//        ActionSheetFrame.origin.y =  ActionSheetFrame.origin.y + 60
//        actionSheet.popoverPresentationController?.sourceRect = ActionSheetFrame
//
//        self.present(actionSheet, animated: true, completion: nil)
//
        
    }
    
//    // *Overide
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//
//            let resizedImage = resizeImage(pickedImage, newWidth: 300)
//            self.userImage = resizedImage
//            self.userImageView.image = resizedImage
//            self.isImageChanged = true
//            self.didShownImagePicker = true
//
//        }
//
//        self.dismiss(animated: true, completion: nil)
//    }
//
//
//    // *Overide
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//
//        self.didShownImagePicker = true
//        self.dismiss(animated: true, completion: nil)
//    }
//
//
//    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
//
//        let scale = newWidth / image.size.width
//        let newHeight = image.size.height * scale
//        UIGraphicsBeginImageContext(CGSize(newWidth, newHeight))
//        image.draw(in: CGRect(0, 0, newWidth, newHeight))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage!
//    }
    
    // MARK: - NonSpecific User Functions
    
    /**
     method send user image to aws
     
     */
    
    
    func prepareUserImageForUpload(){
        
        print("Inside prepareUserImageForUpload")
        let date = NSDate()
        let hashableString = NSString(format: "%f",
                                      date.timeIntervalSinceReferenceDate)
        let s3BucketName = EarnItApp_AWS_BUCKET_NAME
        let imageData: NSData = UIImagePNGRepresentation(self.userImage!)! as NSData
        let hashStr = changePasswordToHexcode(hashableString as String)
        let tempDirectoryUrl = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let fileURL = tempDirectoryUrl.appendingPathComponent(hashStr).appendingPathExtension("png")
        imageData.write(to: fileURL, atomically: true)
        let uploadRequest:
            AWSS3TransferManagerUploadRequest =
            AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = EarnItApp_AWS_BUCKET_NAME
        uploadRequest.acl = AWSS3ObjectCannedACL.publicRead
        uploadRequest.key = "\(EarnItApp_AWS_PARENTIMAGE_FOLDER)/" +
            hashStr + ".png"
        uploadRequest.contentType =
        "image/png"
        uploadRequest.body = fileURL
        let transferManager:AWSS3TransferManager =
            AWSS3TransferManager.default()
        
            transferManager.upload(uploadRequest).continue({ (task) -> AnyObject! in
            
            if task.error != nil {
                
                print("Image Uploading to AWS server failed..")
                if(task.error!._code == -1009){
                    
                    print("error in uploading with error code\(task.error!._code)")
                    
                    self.view.makeToast("You seem to be offline")
//                    let alert = showAlert(title: "Opps", message: "You seem to be offline")
//                    
//                    self.present(alert, animated: true, completion: nil)
                    
                    
                    
                }else if(task.error!._code == -1004){
                    
                    print("error in uploading with error code\(task.error!._code)")
                    
                    self.view.makeToast("Couldn't connect to server")
//                    let alert = showAlert(title: "Opps", message: "Couldn't connect to server")
//                    
//                    self.present(alert, animated: true, completion: nil)
                    
                    
                    
                }else if(task.error!._code == -1001){
                    
                    
                    print("error in uploading with error code\(task.error!._code)")
                    
                    self.view.makeToast("Request timed out")
//                    let alert = showAlert(title: "Opps", message: "Request timed out")
//                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    
                    print("error in uploading with error code\(task.error!._code)")
                    self.view.makeToast("Something went wrong")
//                    let alert = showAlert(title: "Opps", message: "Something went wrong")
//                    
//                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                
            }
            if task.exception != nil {
                
                 self.view.makeToast("Failed to Upload Image")
//                let alert = showAlert(title: "Opps", message: "Failed to Upload Image")
//                self.present(alert, animated: true, completion: nil)
                
            }
            if task.result != nil {
                
                
                self.userImageUrl = String("\(AWS_URL)\(s3BucketName)/\(uploadRequest.key!)")
                
                print("ImageUrl for earnITuser \(self.userImageUrl)")
               
                var contactNumber = String()
                if (self.contactNumber.text?.characters.count)! > 0{
                    
                    contactNumber = "\(self.countryCodeLabel.text!)\(self.contactNumber.text!)"
                }else {
                    
                    contactNumber = ""
                }
                callUpdateProfileImageApiForParent(firstName: self.firstName.text!, lastName: self.lastName.text!, phoneNumber: contactNumber, updatedPassword: EarnItAccount.currentUser.password,userAvatar: self.userImageUrl!, success: {
                    
                    (earnItTask) ->() in
                    
                    let keychain = KeychainSwift()
                    guard  let _ = keychain.get("email") else  {
                        print(" /n Unable to fetch user credentials from keychain \n")
                        return
                    }
                    let email : String = (keychain.get("email")!)
                    let password : String = (keychain.get("password")!)
                    
                    checkUserAuthentication(email: email, password: password, success: {
                        
                        (responseJSON) ->() in
                        
                        
                        EarnItAccount.currentUser.setAttribute(json: responseJSON)
                        keychain.set(String(EarnItAccount.currentUser.accountId), forKey: "userId")
              
                        
                        
                    }) { (error) -> () in
                        
                        self.dismissScreenToLogin()
                        
//                        let alert = showAlertWithOption(title: "Authentication failed", message: "please login again")
//                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreenToLogin))
//                        self.present(alert, animated: true, completion: nil)
//                        
                    }
                    
                }) { (error) -> () in
                    
                    self.view.makeToast("Update Profile Failed")
//                    let alert = showAlert(title: "Error", message: "Update Profile Failed")
//                    self.present(alert, animated: true, completion: nil)
//                    print(" Set status completed failed")
                }
                
            }
                
            else {
                
                
                self.view.makeToast("Update Profile Failed")
//                let alert = showAlert(title: "Opps", message: "Failed to Upload Image")
//                self.present(alert, animated: true, completion: nil)
                
                return nil
                
            }
            
            return nil
            
        })
        
    }
    
    
    
    //Change passwordToHexcode method
    
    func changePasswordToHexcode(_ string: String) -> String {
        
        let data = string.data(using: .utf8)!
        let hexString = data.map{ String(format:"%02x", $0) }.joined()
        return hexString
        
    }
    
    
    func fetchParentUserDetailFromBackground(){
        
        DispatchQueue.global().async {
            
            let keychain = KeychainSwift()
            guard  let _ = keychain.get("email") else  {
                print(" /n Unable to fetch user credentials from keychain \n")
                return
            }
            let email : String = (keychain.get("email")!)
            let password : String = (keychain.get("password")!)
            
            checkUserAuthentication(email: email, password: password, success: {
                
                (responseJSON) ->() in
                
                if (responseJSON["userType"].stringValue == "CHILD"){
                    
                    EarnItChildUser.currentUser.setAttribute(json: responseJSON)
                    //success(true)
                    
                }else {
                    
                    let keychain = KeychainSwift()
                    if responseJSON["token"].stringValue != keychain.get("token") || responseJSON["token"] == nil{
                        
                    }
                    EarnItAccount.currentUser.setAttribute(json: responseJSON)
                    keychain.set(String(EarnItAccount.currentUser.accountId), forKey: "userId")
                    // success(true)
                }
                
            }) { (error) -> () in
                
                  self.dismissScreenToLogin()
//                let alert = showAlertWithOption(title: "Authentication failed", message: "please login again")
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreenToLogin))
//                self.present(alert, animated: true, completion: nil)
                
            }
            
            DispatchQueue.main.async {
                
                print("done calling background fetch for Parent....")
                
                if EarnItAccount.currentUser.email != nil{
                    
                    self.prepareView()
                    
                    
                }
                
                
            }
            
        }
        
    }
    
    func dismissScreenToLogin(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
        self.present(loginController, animated: true, completion: nil)
        
    }


    
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return 1
//    }
// 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
       return self.earnItChildUsers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSection  = 0
        
        if self.earnItChildUsers.count > 0{
            
            numberOfSection = 1
            
        }else {
            
            numberOfSection = 0
        }
        
        print("numberOfSection \(numberOfSection)")
        return numberOfSection

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("yes selected....")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var childCell = self.childUserTable.dequeueReusableCell(withIdentifier: "ChildCell", for: indexPath as IndexPath) as! ChildCell

        childCell.childName.text = self.earnItChildUsers[indexPath.row].firstName
        childCell.childImageView.loadImageUsingCache(withUrl: self.earnItChildUsers[indexPath.row].childUserImageUrl!)
        return childCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view  = Bundle.main.loadNibNamed("ChildListHeader", owner: nil, options: nil)?.first as! ChildListHeader
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print("willDisplayCell")
        self.childTableHeightConstraint.constant = self.childUserTable.contentSize.height
        self.scrollView.contentSize = CGSize(290, childTableHeightConstraint.constant + 600)
        //self.bottomView.frame.origin.y =  self.childUserTable.frame.origin.y
        
    }
    
    func showLoadingView(){
        
        self.view.alpha = 0.7
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        
    }
    
    func hideLoadingView(){
        
        self.view.alpha = 1
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
     
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
           
            textField.resignFirstResponder()
        }
      
        return false
    }
    
    @IBAction func showSideMenu(_ sender: Any) {
        
        //self.openLeft()
    }


    //MARK: -Keypad Butoons
    func addButtonsOnKeyboard()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      //  let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeButtonPressed))
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.contactNumber.inputAccessoryView = toolBar
        self.countryCodeField.inputAccessoryView = toolBar

        
    }
    
    func doneButtonPressed()
    {
        self.view.endEditing(true)
       // self.UpdateButtonClicked(UIButton())
        
    }
    func closeButtonPressed()
    {
        self.view.endEditing(true)
    }

    @IBAction func countryCodeDidTapped(_ sender: Any) {
        
        if isCountryPickerShown {
            
            isCountryPickerShown = false
            self.countryCodeField.resignFirstResponder()
            
        }
        else {
            isCountryPickerShown = true
            self.countryCodeField.becomeFirstResponder()
        }
    }
    
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(newWidth, newHeight))
        image.draw(in: CGRect(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    private func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "CountryList", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as?  [Dictionary<String,String>] {
                    // json is an array
                    
                    countryList = object
                    
                    print(object)
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
        
}

extension ParentProfilePage:UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (countryList?.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return countryList![row]["name"]
    }
}

extension ParentProfilePage:UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedCountryDetails = countryList![row]
        self.countryNameLabel.text = selectedCountryDetails["code"]
        self.countryCodeLabel.text = selectedCountryDetails["dial_code"]
        
    }
}
