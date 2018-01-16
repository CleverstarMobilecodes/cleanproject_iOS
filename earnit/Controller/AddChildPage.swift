//
//  AddChildPage.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/5/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
import AVFoundation
import AWSS3
import KeychainSwift
import ALCameraViewController

class AddChildPage : UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate{
    
    @IBOutlet var welcomeText: UILabel!
  
    @IBOutlet var firstName: UITextField!
    
    @IBOutlet var lastName: UITextField!
    
    @IBOutlet var email: UITextField!
    
    @IBOutlet var phone: UITextField!
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var confirmPassword: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var welcomeLabel: UILabel!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var countryCodeField: UITextField!
    @IBOutlet var countryNameLabel: UILabel!
    @IBOutlet var countryCodeLabel: UILabel!
    
    
    var activeField: UITextField?
   
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var isConfirmPasswordCorrect = Bool()
    var isEmailValid = Bool()
    var isImageChanged: Bool?
    var userImage: UIImage!
    var imagePicker : UIImagePickerController!
    var userImageUrl : String?
    var isInEditingMode = false
    var earnItChildUser = EarnItChildUser()
    var childImageUrl : String!
    var currentKeyboardOffset : CGFloat = 0.0
    
    var counrtyPicker = UIPickerView()
    var countryList : [Dictionary<String, String>]?
    var isCountryPickerShown = false
    var selectedCountryDetails : [String:String]!
    
    @IBAction func emailDidChanged(_ sender: Any) {
        
        if (email.text?.isEmail)! {
            
            self.isEmailValid = true
        }else {
            
            self.isEmailValid = false
            
        }
        
    }
    override func viewDidLoad() {
       
        _ = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.fetchParentUserDetailFromBackground), userInfo: nil, repeats: true)
        self.readJson()
        self.childImageUrl = ""
        self.userImageView.image = EarnItImage.defaultUserImage()
       
        self.isImageChanged = false
        self.requestObserver()
        self.assignLeftPaddingForTF()
        self.addButtonsOnKeyboard()
        //self.welcomeLabel.text = "Welcome" + EarnItAccount.currentUser.firstName
        
         self.counrtyPicker.dataSource = self
          self.counrtyPicker.delegate = self
          self.countryCodeField.inputView = counrtyPicker
        
        
        selectedCountryDetails = countryList![0]
        self.countryNameLabel.text = selectedCountryDetails["code"]
        self.countryCodeLabel.text = selectedCountryDetails["dial_code"]
        
         self.setUpEditViewForChild()
    }
    
    
    func assignLeftPaddingForTF() {
        
        self.creatLeftPadding(textField: firstName)
        self.creatLeftPadding(textField: email)
        self.creatLeftPadding(textField: password)
        self.creatLeftPadding(textField: confirmPassword)
        //self.creatLeftPadding(textField: phone)
    }
    
   

    @IBAction func confirmPasswordDidEndEditing(_ sender: Any) {
      
        if self.password.text != self.confirmPassword.text {
            
            self.isConfirmPasswordCorrect = false
            
        }else {
            
           self.isConfirmPasswordCorrect = true
        }
        
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        self.showLoadingView()
        
        if (self.firstName.text?.characters.count == 0 && self.phone.text?.characters.count == 0 && self.email.text?.characters.count == 0 && self.password.text?.characters.count == 0 && self.confirmPassword.text?.characters.count == 0){
            
            self.view.makeToast("Please complete all fields")
            self.hideLoadingView()
        }
        
        
        if (self.firstName.text?.characters.count == 0 || self.email.text?.characters.count == 0 || self.phone.text?.characters.count == 0 || self.password.text?.characters.count == 0){

            
            var errorFields = "\(self.firstName.text?.characters.count == 0 ? " Name and":"")\(self.email.text?.characters.count == 0 ? " Email and":"")\(self.phone.text?.characters.count == 0 ? " Phone and":"")\(self.password.text?.characters.count == 0 ? " Password":"")"
            
            let last3 = errorFields.substring(from:errorFields.index(errorFields.endIndex, offsetBy: -3))
            
            
            if last3 == "and" {
                errorFields = errorFields.substring(to: errorFields.index(errorFields.endIndex, offsetBy: -3))
            }
            
            self.view.makeToast("Please complete \(errorFields) field")
            self.hideLoadingView()

        }
            
        else if  (self.phone.text?.characters.count)! < 10 {
            self.hideLoadingView()
            self.view.makeToast("Please enter valid phone number")
        }
         
        else if self.isEmailValid == false{
            
            self.view.makeToast("Please enter a valid email")

            self.hideLoadingView()
            
        }else if self.isConfirmPasswordCorrect == false {
            
            self.view.makeToast("Entered Password doesn't match with confirm password")
            self.password.text = ""
            self.confirmPassword.text = ""
            self.hideLoadingView()
        }
            
            
        else {
            
            if self.isImageChanged == true{
                
                DispatchQueue.global().async {
                    
                    self.prepareUserImageForUpload()
                    
                    DispatchQueue.main.async {
                        
                        print("Done with image Upload and updated to backend!")
                    }
                }
                
                //self.prepareUserImageForUpload()
                
            }
            
            let contactNumber = "\(self.countryCodeLabel.text!)\(self.phone.text!)"
            
                if self.isInEditingMode == true{
                    
                    self.callUpdateForChild(firstName: self.firstName.text!,email: self.email.text!,password: self.password.text!,childAvatar: self.childImageUrl,phoneNumber: contactNumber)
                    
                }else {
                    
                     self.callSignUpForChild(firstName: self.firstName.text!,email: self.email.text!,password: self.password.text!,childAvatar: "",phoneNumber: contactNumber)
                    
                }
        
        }
    }
    
    
    func callSignUpForChild(firstName: String,email: String,password: String,childAvatar: String,phoneNumber: String){
        
        print("calling signUp....")
        self.showLoadingView()
        callSignUpApiForChild(firstName: firstName,email: email,password: password,childAvatar: self.childImageUrl,phoneNumber: phoneNumber, success: {
            
            (earnItChild,errorcode) ->() in
            
            self.earnItChildUser = earnItChild
            
            
            if (errorcode == "9000"){
                
                self.view.makeToast("A child user with this email already exist")
//                let alert = showAlert(title: "", message: "A child user with this email already exist")
//                self.present(alert, animated: true, completion: nil)
                self.firstName.text = ""
                self.phone.text = ""
                self.email.text = ""
                self.password.text = ""
                self.confirmPassword.text = ""
                self.userImageView.image = EarnItImage.defaultUserImage()
                self.hideLoadingView()
                
            }else {
            
            createEarnItAppChildUser( success: {
                
                (earnItChildUsers) -> () in
                
                for user in earnItChildUsers {
                    
                    for task in user.earnItTasks {
                        
                        print(task.taskId)
                        print(task.taskName)
                    }
                    
                    for task in user.earnItTopThreePendingApprovalTask{
                        
                        print("task.taskName \(task.taskName)")
                    }
                }
                
                EarnItAccount.currentUser.earnItChildUsers = earnItChildUsers
                
                print("EarnItAccount.currentUser.earnItChildUsers.count in profile page \(EarnItAccount.currentUser.earnItChildUsers.count )")

                self.view.makeToast(" \(self.firstName.text!) added")
                self.dismissScreen()
//                let alert = showAlertWithOption(title: "", message: " \(self.firstName.text!) added")
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreen))
//                self.present(alert, animated: true, completion: nil)

                self.hideLoadingView()
                
                
            }) {  (error) -> () in
                
                print("error")
                
            }
            
        }
            
            
    }) { (error) -> () in
            self.hideLoadingView()
        self.view.makeToast("Add Child Failed")
//            let alert = showAlert(title: "Error", message: "Add Child Failed")
//            self.present(alert, animated: true, completion: nil)
//            print(" Set status completed failed")
        }
        
    }
    
    func callUpdateForChild(firstName: String,email: String,password: String,childAvatar: String,phoneNumber: String){
        
        print("calling update....")
        self.showLoadingView()
        let keychain = KeychainSwift()
        let fcmToken : String? = keychain.get("token")
        callUpdateApiForChild(firstName: firstName,childEmail: email,childPassword: password,childAvatar: self.childImageUrl,createDate: self.earnItChildUser.createDate,childUserId: self.earnItChildUser.childUserId, childuserAccountId: self.earnItChildUser.childAccountId,phoneNumber: phoneNumber, fcmKey: fcmToken, message: self.earnItChildUser.childMessage, success: {
            
            (earnItTask) ->() in
            
            createEarnItAppChildUser( success: {
                
                (earnItChildUsers) -> () in
                
                for user in earnItChildUsers {
                    
                    for task in user.earnItTasks {
                        
                        print(task.taskId)
                        print(task.taskName)
                    }
                    
                    for task in user.earnItTopThreePendingApprovalTask{
                        
                        print("task.taskName \(task.taskName)")
                    }
                }
                
                EarnItAccount.currentUser.earnItChildUsers = earnItChildUsers
                self.view.makeToast(" \(self.firstName.text!) updated")
                self.dismissScreen()
//                let alert = showAlertWithOption(title: "", message: " \(self.firstName.text!) updated")
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreen))
//                self.present(alert, animated: true, completion: nil)
                self.hideLoadingView()
                
                
            }) {  (error) -> () in
                
                print("error")
                
            }
            
            
        }) { (error) -> () in
            self.hideLoadingView()
            self.view.makeToast("Update Child Failed")
//            let alert = showAlert(title: "Error", message: "Update Child Failed")
//            self.present(alert, animated: true, completion: nil)
            print(" Set status completed failed")
        }

    }
    
    @IBAction func viewDidTapped(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    func dismissScreen(){
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
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
//        self.dismiss(animated: true, completion: nil)
//    }
//
//
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(newWidth, newHeight))
        image.draw(in: CGRect(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!

    }
    
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
        uploadRequest.key = "\(EarnItApp_AWS_CHILDIMAGE_FOLDER)/" +
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
                
                
                self.childImageUrl = String("\(AWS_URL)\(s3BucketName)/\(uploadRequest.key!)")
                
                let contactNumber = "\(self.countryCodeLabel.text!)\(self.phone.text!)"
                
                    if self.isInEditingMode == true{
                        
                         self.callUpdateForChild(firstName: self.firstName.text!,email: self.email.text!,password: self.password.text!,childAvatar: self.childImageUrl, phoneNumber: contactNumber)
                        
                    }else {
                        
                        
                        self.callUpdateForChild(firstName: self.firstName.text!,email: self.email.text!,password: self.password.text!,childAvatar: self.childImageUrl, phoneNumber: contactNumber)
                       
                    }

                
            }
                
            else {
                
                self.view.makeToast("Failed to Upload Image")
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
  
    func showLoadingView(){
        self.view.endEditing(true)
        self.view.alpha = 0.7
        self.view.isUserInteractionEnabled = false
        self.view.bringSubview(toFront: self.activityIndicator)
        self.activityIndicator.startAnimating()
        
    }
    
    
    func hideLoadingView(){
        
        self.view.alpha = 1
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
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
            
//                            let alert = showAlertWithOption(title: "Authentication failed", message: "please login again")
//                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreenToLogin))
//                            self.present(alert, animated: true, completion: nil)
            
                        }
            
                        DispatchQueue.main.async {
            
                            print("done calling background fetch for Parent....")
            
                        }
                    }
                    
    }
    
        func dismissScreenToLogin(){
            
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
                   self.present(loginController, animated: true, completion: nil)
           
    }
    
    
    
    
    func setUpEditViewForChild(){
        
        if self.isInEditingMode == true{
            
            self.welcomeLabel.text = "Edit" + " " + self.earnItChildUser.firstName
            self.firstName.text = self.earnItChildUser.firstName
            self.email.text = self.earnItChildUser.email
            self.password.text = self.earnItChildUser.password
            self.confirmPassword.text = self.earnItChildUser.password
            
           
                
          self.phone.text = self.getPhoneNumber()
            self.userImageView.loadImageUsingCache(withUrl: self.earnItChildUser.childUserImageUrl)
            self.saveButton.setTitle("Update", for: .normal)
            self.childImageUrl = self.earnItChildUser.childUserImageUrl?.replacingOccurrences(of: "\"", with:  " ")
            self.isConfirmPasswordCorrect = true
            self.isEmailValid = true
            
            self.setCountryCode()
        }
        
    }
    
    
    func getPhoneNumber() -> String {
        
        let phoneNo = self.earnItChildUser.phoneNumber as! String
        let last10  = String(describing: phoneNo.suffix(10) )
        return last10
    }
    
    func getCountryCode() -> String {
        
        let phoneNo = self.earnItChildUser.phoneNumber as! String
        
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
    
    /**
     Add observer to the View
     
     :param: nil
     */
    
    func requestObserver(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide  , object: nil)
        
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
//                }else  if phone.isFirstResponder {
//                    
//                    let contactNumberYValue = self.phone.frame.size.height + self.phone.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (contactNumberYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - contactNumberYValue + 140
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
//                }else  if phone.isFirstResponder {
//                    
//                    let contactNumberYValue = self.phone.frame.size.height + self.phone.frame.origin.y
//                    
//                    if self.currentKeyboardOffset == 0.0 {
//                        
//                        if (contactNumberYValue ) > keyboardYValue + 10.0 {
//                            
//                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - contactNumberYValue + 180
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
    
    
    
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
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
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        
//        if (textField==firstName) {
//            
//            let characterSet = CharacterSet.letters
//            if string.rangeOfCharacter(from: characterSet.inverted) != nil {
//                return false
//            }
//        }
//        return true
//    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == firstName {
            
            let allowedCharacters = CharacterSet.decimalDigits.inverted
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        else if textField == self.phone {
            let charsLimit = 10
            let startingLength = textField.text?.characters.count ?? 0
            let lengthToAdd = string.characters.count
            let lengthToReplace =  range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            return newLength <= charsLimit
        }
        
       return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
       
        if textField.tag == 4 {
            
            self.saveButton.sendActions(for: .touchUpInside)
        }
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
        
        let doneButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonPressed))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeButtonPressed))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.phone.inputAccessoryView = toolBar
        
        
        let toolBar2 = UIToolbar()
        toolBar2.barStyle = .default
        toolBar.isTranslucent = true
        toolBar2.sizeToFit()
        
        let doneButton2 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(DoneButtonTapped))
        
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        toolBar2.setItems([ spaceButton2, doneButton2], animated: false)
        toolBar2.isUserInteractionEnabled = true
        
        self.countryCodeField.inputAccessoryView = toolBar2

        
        
    }
    
   
    
    func nextButtonPressed()
    {
        self.password.becomeFirstResponder()
        
    }
    func closeButtonPressed()
    {
        self.view.endEditing(true)
    }
    func DoneButtonTapped()
    {
        self.view.endEditing(true)
    }
    
    @IBAction func countryCodeFieldDidTapped(_ sender: Any) {
        
        if isCountryPickerShown {
            isCountryPickerShown = false
            self.countryCodeField.resignFirstResponder()
        }
        else {
            isCountryPickerShown = true
            self.countryCodeField.becomeFirstResponder()
        }
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

extension AddChildPage {
    
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

extension AddChildPage {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedCountryDetails = countryList![row]
        self.countryNameLabel.text = selectedCountryDetails["code"]
        self.countryCodeLabel.text = selectedCountryDetails["dial_code"]
        
    }
}
    
    
    


    

