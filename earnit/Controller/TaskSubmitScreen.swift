//
//  TaskSubmitScreen.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/23/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
import AVFoundation
import AWSS3
import KeychainSwift
import ALCameraViewController


class TaskSubmitScreen : UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate ,
    UINavigationControllerDelegate,
    UITextViewDelegate{
    
    @IBOutlet var allowance: UILabel!
    @IBOutlet var dueDate: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var taskNameLabel: UILabel!
    @IBOutlet var taskDescription: UILabel!
    @IBOutlet var taskComments: UITextView!
    
    @IBOutlet var taskImageView: UIImageView!
    
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var photoRequiredLabel: UILabel!
    @IBOutlet  var scrollView: UIScrollView!
    @IBOutlet  var isPhotoRequiredLabel: UILabel!
    
    
   
    
    @IBOutlet var submitButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var repeatsLabel: UILabel!
    var activeTextView:UITextView?
    
    var earnItTask = EarnItTask()
    
    //imagePicker
    var imagePicker : UIImagePickerController!
    
    var isPictureRequired  = 0
    
    var taskImage: UIImage!
    
    var taskImageUrl : String?
    
    var isImageChanged = Bool()
    
    var currentKeyboardOffset : CGFloat = 0.0
    let colonSpace = ": "
    
    override func viewDidLoad() {
        
        self.isImageChanged = false
        self.taskComments.delegate = self
        self.taskComments.autocorrectionType = .no
        self.taskNameLabel.text = self.earnItTask.taskName
    
        print(self.earnItTask)
        
        if(self.earnItTask.taskDescription == ""){
            
              self.taskDescription.text  = "No description available"
            self.taskDescription.alpha = 0.5
            
        }else{
            
              self.taskDescription.text = self.earnItTask.taskDescription
            self.taskDescription.alpha = 1.0

        }
        
        
        if self.earnItTask.repeatMode == .None {
            
            self.repeatsLabel.text = colonSpace + "No"
        }
        else {
             self.repeatsLabel.text = colonSpace + self.earnItTask.repeatMode.rawValue.capitalized
        }
      
        
        self.allowance.text = colonSpace + "$" + String(self.earnItTask.allowance)
        self.dueDate.text = colonSpace + self.earnItTask.dateMonthString + " @ " + self.earnItTask.dueTime
        
        self.isPictureRequired = self.earnItTask.isPictureRequired
        
        if self.isPictureRequired == 1{
            
            self.taskImageView.alpha = 1
            self.photoRequiredLabel.alpha = 1
     
            self.isPhotoRequiredLabel.text = colonSpace +  "Yes"
        }else {
            
            self.taskImageView.alpha = 0
            self.photoRequiredLabel.alpha = 0
            
            self.isPhotoRequiredLabel.text = colonSpace + "No"
            self.submitButtonTopConstraint.constant = -10
          
        }
        
        self.setImagePicker()
        self.requestObserver()
    }
    
    func setImagePicker(){
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        
        print("task submit clicked...")
        self.view.endEditing(true)
       
        
        if self.isPictureRequired == 1 {
            
            if self.isImageChanged == true{
                
                print("self.isImageChanged \(self.isImageChanged)")
                
                
                DispatchQueue.global().async {
                    
                    self.prepareTaskImageForUpload()
                    
                    DispatchQueue.main.async {
                        
                        print("Done with image Upload and updated to backend!")
                        self.callControllerForDoneTask()

                    }
                }
            
                
            }else {
                
                self.hideLoadingView()
           
                self.view.makeToast("Please upload an image to set this task complete")
//                let alert = showAlert(title: "", message: "Please upload an image to set this task complete")
//                
//                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        else{
            self.callControllerForDoneTask()
        }
        
    }
    @IBAction func taskImageViewDidTap(_ sender: Any) {

        

        
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
                self?.taskImage = resizedImage
                self?.isImageChanged = true
                self?.taskImageView.image = resizedImage
//                self?.taskImage = image
//                self?.isImageChanged = true
//                self?.taskImageView.image = image
                self?.view.layoutIfNeeded()
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
        

        
        return
        
        
        print("ImageView got tapped")
        
        let actionSheet = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) -> Void in
                
                if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized
                {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    self.present(self.imagePicker, animated: true, completion: nil)
                    
                }
                else
                {
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                        if granted == true
                        {
                            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                            self.present(self.imagePicker, animated: true, completion: nil)
                            
                        }
                        else
                        {
                            self.view.makeToast("You don't have permission to access camera")
//                            let alert = showAlert(title: "Not allowed", message: "You don't have permission to access camera")
//                            
//                            self.present(alert, animated: true, completion: nil)
                            
                        }
                    });
                }
                
                
            }
            actionSheet.addAction(cameraAction)
        }
        
        let albumAction = UIAlertAction(title: "Photo Library", style: .default) { (action) -> Void in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        actionSheet.addAction(albumAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        actionSheet.popoverPresentationController?.sourceView = self.view
        
        var ActionSheetFrame = taskImageView.frame
        ActionSheetFrame.origin.y =  ActionSheetFrame.origin.y + 100
        actionSheet.popoverPresentationController?.sourceRect = ActionSheetFrame

        self.present(actionSheet, animated: true, completion: nil)

    }
    
    
//    // *Overide
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//
////            let resizedImage = resizeImage(pickedImage, newWidth: 300)
////            self.taskImage = resizedImage
////            self.isImageChanged = true
////            self.taskImageView.image = resizedImage
//
//            self.dismiss(animated: false) {
//                self.showImageCropper(image: pickedImage)
//            }
//        }
//
//        self.dismiss(animated: true, completion: nil)
//    }
    
    
    func showImageCropper(image:UIImage)  {
        
        
        
        let cameraViewController = CameraViewController { [weak self] image, asset in
            // Do something with your image here.
            self?.dismiss(animated: true, completion: nil)
        }
        
        self.present(cameraViewController, animated: true, completion: nil)
        
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let imageCropper  = storyBoard.instantiateViewController(withIdentifier: "ImageCropperControllor") as! ImageCropperControllor
//       imageCropper.imagetoEdit = image
//        imageCropper.delegate = self
//        self.present(imageCropper, animated:false, completion:nil)
    }
    
    // *Overide
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
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
    
    // MARK: - NonSpecific User Functions
    
    /**
     method send user image to aws
     
     */
    
    
    func prepareTaskImageForUpload(){
        
        print("Inside prepareUserImageForUpload")
        let date = NSDate()
        let hashableString = NSString(format: "%f",
                                      date.timeIntervalSinceReferenceDate)
        let s3BucketName = EarnItApp_AWS_BUCKET_NAME
        let imageData: NSData = UIImagePNGRepresentation(self.taskImage!)! as NSData
        let hashStr = changePasswordToHexcode(hashableString as String)
        let tempDirectoryUrl = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let fileURL = tempDirectoryUrl.appendingPathComponent(hashStr).appendingPathExtension("png")
        imageData.write(to: fileURL, atomically: true)
        let uploadRequest:
            AWSS3TransferManagerUploadRequest =
            AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = EarnItApp_AWS_BUCKET_NAME
        uploadRequest.acl = AWSS3ObjectCannedACL.publicRead
        uploadRequest.key = "\(EarnItApp_AWS_BUCKET_NAME)/\(EarnItApp_AWS_TASKIMAGE_FOLDER)" +
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
                
                
                self.taskImageUrl = String("\(AWS_URL)\(s3BucketName)/\(uploadRequest.key!)")
                
                print("ImageUrl for earnITuser \(self.taskImageUrl)")
                self.callControllerForDoneTask()
                

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
    
    
    @IBAction func goBackButtonClicked(_ sender: Any) {
        
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func viewDidTap(_ sender: Any) {
//        
//        print("self.view tapped")
//        self.view.endEditing(true)
//    }
//    
    
    //ovrride
    func callControllerForDoneTask() {
        
        //self.completedTask.status = TaskStatus.completed
        
        self.showLoadingView()
        
        var taskComment = TaskComment()
        
        if self.taskComments.text.characters.count  > 0 {
            
            taskComment.comment = self.taskComments.text
            
        }
        else
        {
            taskComment.comment = ""
        }
        
        taskComment.createdDate = Date().millisecondsSince1970
        taskComment.taskImageUrl = self.taskImageUrl
        taskComment.readStatus = 0
        self.earnItTask.status = TaskStatus.completed
        self.earnItTask.taskComments.append(taskComment)
        
        
        //self.earnItTask.taskComments.append(self.taskComments.text)
        callApiForUpdateTask(earnItTaskChildId: EarnItChildUser.currentUser.childUserId,earnItTask: self.earnItTask, success: {
            
            (earnItTask) ->() in
            
            let keychain = KeychainSwift()
            //let _ : Int = Int(keychain.get("userId")!)!
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
                    self.hideLoadingView()
                    
                    self.view.makeToast("Task submitted")
                    self.dismissscreen()
//                    let alert = showAlertWithOption(title: "", message: "Task submitted")
//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissscreen))
//                    self.present(alert, animated: true, completion: nil)
                    
                    
                }else {
                    
       
                }
                
            }) { (error) -> () in
                
                
                
            }
            

            
        }) { (error) -> () in
            
            self.hideLoadingView()
            self.view.makeToast("Task submission failed")
//            let alert = showAlert(title: "Error", message: "Failed")
//            self.present(alert, animated: true, completion: nil)
//            print(" Set status completed failed")
            self.hideLoadingView()
        }
        
    }
    
    
    func dismissscreen(){
        
        self.dismiss(animated: true, completion: nil)
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


    
    
    @IBAction func viewDidTap(_ sender: Any) {
        
        print("viewDidTap")
        self.view.endEditing(true)
    }
    
    
    /**
     Add observer to the View
     
     :param: nil
     */
    
    func requestObserver(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide  , object: nil)
        
    }
    



    
    func keyboardWillShow(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        
        
        if let activeTextView = self.activeTextView {
            
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height+50, 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect : CGRect = self.view.frame
            aRect.size.height -= keyboardSize!.height
            
            //            if (!aRect.contains(activeTextView.frame.origin)){
            
            self.scrollView.scrollRectToVisible(activeTextView.frame, animated: true)
            //    }
            
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTextView = textView
        return true
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }

}











