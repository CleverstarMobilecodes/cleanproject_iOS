//
//  FirstTimeLoginProfileScreen.swift
//  earnit
//
//  Created by Srivathsa on 29/09/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import UIKit
import KeychainSwift
import AWSS3
import AVFoundation
import ALCameraViewController

class FirstTimeLoginProfileScreen: UIViewController, UINavigationControllerDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,UIPickerViewDataSource,UIPickerViewDelegate {

    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var countryCodeField: UITextField!
    @IBOutlet var countryNameLabel: UILabel!
    @IBOutlet var countryCodeLabel: UILabel!
    
    var imagePicker : UIImagePickerController!
    var isImageChanged: Bool?
    var userImageUrl : String?
    var userImage: UIImage!
    var didShownImagePicker = false
    var activeField : UITextField?
    var counrtyPicker = UIPickerView()
    var countryList : [Dictionary<String, String>]?
    var isCountryPickerShown = false
    var selectedCountryDetails : [String:String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.isImageChanged = false

        profileImageView.loadImageUsingCache(withUrl: EarnItAccount.currentUser.avatar!)
        self.creatLeftPadding(textField: firstNameField)
        self.creatLeftPadding(textField: lastNameField)
        self.creatLeftPadding(textField: phoneField)
        self.userImageUrl = EarnItAccount.currentUser.avatar?.replacingOccurrences(of: "\"", with:  " ")
        self.requestObserver()
        self.hideLoadingView()
        self.addButtonsOnKeyboard()
        
        counrtyPicker.dataSource = self
        counrtyPicker.delegate = self
        countryCodeField.inputView = counrtyPicker
        
        self.readJson()
        selectedCountryDetails = countryList![0]
        self.countryNameLabel.text = selectedCountryDetails["code"]
        self.countryCodeLabel.text = selectedCountryDetails["dial_code"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
   
    func requestObserver(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide  , object: nil)
        
    }
    
    
    //MARK: -Keypad Button Methods
    func addButtonsOnKeyboard()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))

        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
       // let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeButtonPressed))

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        self.phoneField.inputAccessoryView = toolBar
        self.countryCodeField.inputAccessoryView = toolBar
    }
    
    func doneButtonPressed()
    {
        self.view.endEditing(true)

    }
    func closeButtonPressed()
    {
        self.view.endEditing(true)
    }
    
    @IBAction func ViewDidTapped(_ sender: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
    @IBAction func profileImageDidTapped(_ sender: UIButton)
        
        {
    
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
                self?.profileImageView.image = resizedImage
                self?.isImageChanged = true
                self?.didShownImagePicker = true
            }
                self?.dismiss(animated: true, completion: nil)

            }
            present(cameraViewController, animated: true, completion: nil)
            
            
            
            return
            
            
            
            
            
            
            
            
//            let actionSheet = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
//            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
//                let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) -> Void in
//
//                    if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized
//                    {
//                        self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//                        self.present(self.imagePicker, animated: true, completion: nil)
//
//                    }
//                    else
//                    {
//                        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
//                            if granted == true
//                            {
//                                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//                                self.present(self.imagePicker, animated: true, completion: nil)
//
//                            }
//                            else
//                            {
//
//                                self.view.makeToast("You don't have permission to access camera")
//                                //                            let alert = showAlert(title: "Not allowed", message: "You don't have permission to access camera")
//                                //
//                                //                            self.present(alert, animated: true, completion: nil)
//
//                            }
//                        });
//                    }
//
//
//                }
//                actionSheet.addAction(cameraAction)
//            }
//
//            let albumAction = UIAlertAction(title: "Photo Library", style: .default) { (action) -> Void in
//                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//                self.present(self.imagePicker, animated: true, completion: nil)
//            }
//
//            actionSheet.addAction(albumAction)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            actionSheet.addAction(cancelAction)
//            actionSheet.popoverPresentationController?.sourceView = self.view
//            
//            var ActionSheetFrame = self.profileImageView.frame
//            ActionSheetFrame.origin.y =  ActionSheetFrame.origin.y + 60
//            actionSheet.popoverPresentationController?.sourceRect = ActionSheetFrame
//
//            self.present(actionSheet, animated: true, completion: nil)
            
            
        }
        
    
    @IBAction func cancelButtonDidTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonDidTapped(_ sender: Any) {
        
        
        EarnItAccount.currentUser.firstName = self.firstNameField.text
        EarnItAccount.currentUser.lastName = self.lastNameField.text
        
        var contactNumber = String()
        if (self.phoneField.text?.characters.count)! > 0{
            
            contactNumber = "\(self.countryCodeLabel.text!)\(self.phoneField.text!)"
        }else {
            
            contactNumber = ""
        }
        EarnItAccount.currentUser.phoneNumber = contactNumber
        
        print("SaveButtonClicked ")
      

        if (self.firstNameField.text?.characters.count == 0 && self.phoneField.text?.characters.count == 0 && self.lastNameField.text?.characters.count == 0){
            
            self.view.makeToast("Please complete all fields")
           
        }
        
        
        if (self.firstNameField.text?.characters.count == 0 || self.phoneField.text?.characters.count == 0 || self.lastNameField.text?.characters.count == 0){
            
            var errorFields = "\(self.firstNameField.text?.characters.count == 0 ? "First name and":"")\(self.lastNameField.text?.characters.count == 0 ? " Last name and":"")\(self.phoneField.text?.characters.count == 0 ? " Phone":"")"
            
            let last3 = errorFields.substring(from:errorFields.index(errorFields.endIndex, offsetBy: -3))
            
            
            if last3 == "and" {
                errorFields = errorFields.substring(to: errorFields.index(errorFields.endIndex, offsetBy: -3))
            }
            
            self.view.makeToast("Please complete \(errorFields) field")
            
        }
            
        else if  (self.phoneField.text?.characters.count)! < 10 {
            
            self.view.makeToast("Please enter valid phone number")
        }

       else {
            
            
            var contactNumber = String()
            if (self.phoneField.text?.characters.count)! > 0{
                
                contactNumber = "\(self.countryCodeLabel.text!)\(self.phoneField.text!)"
            }else {
                
                contactNumber = ""
            }
            EarnItAccount.currentUser.phoneNumber = contactNumber
            
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
            callUpdateProfileApiForParentt(firstName: self.firstNameField.text!, lastName:self.lastNameField.text!, phoneNumber: contactNumber, updatedPassword: EarnItAccount.currentUser.password,imageUrl: self.userImageUrl!, fcmKey: fcmToken,success: {
                
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
         
                    
                    EarnItAccount.currentUser.setAttribute(json: responseJSON)
                    keychain.set(String(EarnItAccount.currentUser.accountId), forKey: "userId")
                    keychain.set(true, forKey: "isProfileUpdated")
                    self.hideLoadingView()
                    
                    // success(true)
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

                    let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
                    
                    let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                    
                    let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
                    
                    slideMenuController.automaticallyAdjustsScrollViewInsets = true
                    slideMenuController.delegate = parentLandingPage
                    
                    self.present(slideMenuController, animated:false, completion:nil)
                    
                    
                    
                }) { (error) -> () in
                    self.hideLoadingView()
                    self.view.makeToast("Update Profile Failed")

               
                    
                }
                
                
            }) { (error) -> () in
            
                self.hideLoadingView()
                self.view.makeToast("Update Profile Failed")
            
            }
            
        }
        
        
    }
    
    
    
    //MARK: -Custom Methods
    
    func creatLeftPadding(textField:UITextField) {
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.size.height))
        textField.leftView = leftPadding
        textField.leftViewMode = UITextFieldViewMode.always
        
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
        
        if  textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
            
       else if  textField == lastNameField {
            phoneField.becomeFirstResponder()
        }
        else {
            
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    @IBAction func openSideMenu(_ sender: Any) {
        
        self.openLeft()
    }
    
    
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
                if (self.phoneField.text?.characters.count)! > 0{
                    
                    contactNumber = "\(self.countryCodeLabel.text!)\(self.phoneField.text!)"
                }else {
                    
                    contactNumber = ""
                }
                callUpdateProfileImageApiForParent(firstName: self.firstNameField.text!, lastName: self.lastNameField.text! , phoneNumber: contactNumber, updatedPassword: EarnItAccount.currentUser.password,userAvatar: self.userImageUrl!, success: {
                    
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
                        
                     //   self.dismissScreenToLogin()
                        
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
    

    
    //MARK: -KeyBoard Notification Methods
    
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
    
    
    //MARK: -UITextField Delegates
   
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
        
        if (textField==firstNameField) {
            
            let characterSet = CharacterSet.letters
            if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                return false
            }
        }
        else if (textField==lastNameField) {
            
            let characterSet = CharacterSet.letters
            if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                return false
            }
        }
        else if (textField==phoneField) {
            
            let charsLimit = 10
            let startingLength = textField.text?.characters.count ?? 0
            let lengthToAdd = string.characters.count
            let lengthToReplace =  range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            return newLength <= charsLimit
        }
        
        return true
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
    
    
    func changePasswordToHexcode(_ string: String) -> String {
        
        let data = string.data(using: .utf8)!
        let hexString = data.map{ String(format:"%02x", $0) }.joined()
        return hexString
        
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

extension FirstTimeLoginProfileScreen {
    
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

extension FirstTimeLoginProfileScreen {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedCountryDetails = countryList![row]
        self.countryNameLabel.text = selectedCountryDetails["code"]
        self.countryCodeLabel.text = selectedCountryDetails["dial_code"]

    }
}

