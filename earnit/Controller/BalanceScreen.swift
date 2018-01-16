//
//  BalanceScreen.swift
//  earnit
//
//  Created by Lovelini Rawat on 10/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class BalanceScreeen : UIViewController,UITextViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet var GoalName: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var goalNameHeight: NSLayoutConstraint!
    @IBOutlet var totalAccountBalance: UILabel!
    @IBOutlet var cashLabel: UILabel!
    @IBOutlet var goalTotal: UILabel!
    @IBOutlet var userImageView: UIImageView!
    var earnItChildUser =  EarnItChildUser()
    var earnItChildUsers = [EarnItChildUser]()
    var actionView = UIView()
    var messageView = MessageView()
    var constX:NSLayoutConstraint?
    var constY:NSLayoutConstraint?
    var isActiveUserChild = false
    
    override func viewDidLoad() {
        
        
        self.actionView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
        self.actionView.addGestureRecognizer(tapGesture)
        
        self.messageView = (Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?[0] as? MessageView)!
        self.messageView.center = CGPoint(x: self.view.center.x,y :self.view.center.y-80)
        self.messageView.messageText.delegate = self
        
        let userAvatarUrlString = self.earnItChildUser.childUserImageUrl
        
        self.userImageView.loadImageUsingCache(withUrl: self.earnItChildUser.childUserImageUrl)
        
        self.messageView.messageToLabel.text = "Message to  \(self.earnItChildUser.firstName!):"
        
        self.getGoalListForCurrentUser()
        
    }
    
    
    
    func getGoalListForCurrentUser(){
        
        getGoalsForChild(childId : self.earnItChildUser.childUserId,success: {
            
            (earnItGoalList) ->() in
            
            for earnItGoal in earnItGoalList{
                
                self.earnItChildUser.earnItGoal = earnItGoal
                
                if earnItGoal.name == "" || earnItGoal.name == nil {
                    
                     self.GoalName.text = "No goal assigned yet!!"
                    
                }else {
                    
                    self.GoalName.text = earnItGoal.name! + ":  " + "$\(earnItGoal.tally!) of $\(earnItGoal.ammount!)  / \(earnItGoal.tallyPercent!)%"
                }
                
                self.totalAccountBalance.text = "\(earnItGoal.cash! + earnItGoal.tally!)"
                self.cashLabel.text = "\(earnItGoal.cash!)"
                self.goalTotal.text = "\(earnItGoal.tally!)"
                
            }
            
            
            
        })
            
        { (error) -> () in
            
            self.view.makeToast("get goal failed")
            
        }
        
    }

    
    @IBAction func homeButtonClicked(_ sender: Any) {
        
        if self.isActiveUserChild == true {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "childDashBoard") as! ChildDashBoard
            self.present(childDashBoard, animated: true, completion: nil)
            
        }else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
            
            let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
            
            let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
            
            slideMenuController.automaticallyAdjustsScrollViewInsets = true
            slideMenuController.delegate = parentLandingPage
            
            self.present(slideMenuController, animated:false, completion:nil)
        }
       
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func userImageViewGotTapped(_ sender: UITapGestureRecognizer) {
        
        var childOptionView = (Bundle.main.loadNibNamed("ChildOptionView", owner: self, options: nil)?[0] as? ChildOptionView)!
        
        var optionView  = (Bundle.main.loadNibNamed("OptionView", owner: self, options: nil)?[0] as? OptionView)!
        
        
    
        optionView.center = self.view.center
        optionView.userImageView.image = self.userImageView.image
        optionView.frame.origin.y = self.userImageView.frame.origin.y
        optionView.frame.origin.x = self.view.frame.origin.x + 160
        
        
        childOptionView.center = self.view.center
        childOptionView.userImageView.image = self.userImageView.image
        childOptionView.frame.origin.y = self.userImageView.frame.origin.y
        childOptionView.frame.origin.x = self.view.frame.origin.x + 160
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 480:
                
                
                childOptionView.frame.origin.x = self.view.frame.origin.x + 160
                optionView.frame.origin.x = self.view.frame.origin.x + 160
                
                
                
            case 960:
                
                
                childOptionView.frame.origin.x = self.view.frame.origin.x + 160
                optionView.frame.origin.x = self.view.frame.origin.x + 160
                
                
                
            case 1136:
                
                
                childOptionView.frame.origin.x = self.view.frame.origin.x + 100
                optionView.frame.origin.x = self.view.frame.origin.x + 100
                
            case 1334:
                
                
                childOptionView.frame.origin.x = self.view.frame.origin.x + 160
                optionView.frame.origin.x = self.view.frame.origin.x + 160
                
                
            case 2208:
                
                
                childOptionView.frame.origin.x = self.view.frame.origin.x + 200
                optionView.frame.origin.x = self.view.frame.origin.x + 200
                
            default:
                
                print("unknown")
            }
            
        }
        else if  UIDevice().userInterfaceIdiom == .pad {
            
            childOptionView.frame.origin.x = self.view.frame.origin.x + 200
            optionView.frame.origin.x = self.view.frame.origin.x + 200
        }
        
        
        //        optionView.addTaskButton.setImage(EarnItImage.setEarnItAddIcon(), for: .normal)
        //        optionView.showAllTaskButton.setImage(EarnItImage.setEarnItPageIcon(), for: .normal)
        //        optionView.approveTaskButton.setImage(EarnItImage.setEarnItAppShowTaskIcon(), for: .normal)
        //        optionView.showBalanceButton.setImage(EarnItImage.setEarnItAppBalanceIcon(), for: .normal)
        //        optionView.showGoalButton.setImage(EarnItImage.setEarnItGoalIcon(), for: .normal)
        //        optionView.messageButton.setImage(EarnItImage.setEarnItCommentIcon(), for: .normal)
        
        
        
        if self.isActiveUserChild == true {
            
            
            childOptionView.firstOption.setImage(EarnItImage.setEarnItPageIcon(), for: .normal)
            childOptionView.secondOption.setImage(EarnItImage.setEarnItAppBalanceIcon(), for: .normal)
            childOptionView.thirdOption.setImage(EarnItImage.setEarnItLogoutIcon(), for: .normal)
            //optionView.sixthOption.setImage(EarnItImage.setEarnItCommentIcon(), for: .normal)
            
            childOptionView.firstOption.setTitle("View Tasks", for: .normal)
            childOptionView.secondOption.setTitle("Balances", for: .normal)
            childOptionView.thirdOption.setTitle("Logout", for: .normal)
            
            
            
            childOptionView.doActionForFirstOption = {
                
                self.removeActionView()
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "childDashBoard") as! ChildDashBoard
                self.present(childDashBoard, animated: true, completion: nil)
                
                
            }
            
            childOptionView.doActionForSecondOption = {
                
                
                self.removeActionView()
                
            }
            
            childOptionView.doActionForThirdOption = {
                
                self.removeActionView()
                let keychain = KeychainSwift()
                keychain.delete("isActiveUser")
                keychain.delete("email")
                keychain.delete("password")

                keychain.delete("isProfileUpdated")
                keychain.delete("token")

                //keychain.delete("token")
                //self.stopTimerForFetchingUserDetail()
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
                self.present(loginController, animated: false, completion: nil)
                
            }
            
            self.actionView.addSubview(childOptionView)
            self.actionView.backgroundColor = UIColor.clear
            self.view.addSubview(self.actionView)
            
            
        } else  {
        
        optionView.firstOption.setImage(EarnItImage.setEarnItAddIcon(), for: .normal)
        optionView.secondOption.setImage(EarnItImage.setEarnItPageIcon(), for: .normal)
        optionView.thirdOption.setImage(EarnItImage.setEarnItAppShowTaskIcon(), for: .normal)
        optionView.forthOption.setImage(EarnItImage.setEarnItAppBalanceIcon(), for: .normal)
        optionView.fifthOption.setImage(EarnItImage.setEarnItGoalIcon(), for: .normal)
        optionView.sixthOption.setImage(EarnItImage.setEarnItCommentIcon(), for: .normal)
        
        optionView.firstOption.setTitle("Add Task", for: .normal)
        optionView.secondOption.setTitle("All Task", for: .normal)
        optionView.thirdOption.setTitle("Approve Task", for: .normal)
        optionView.forthOption.setTitle("Balances", for: .normal)
        optionView.fifthOption.setTitle("Goals", for: .normal)
        optionView.sixthOption.setTitle("Message", for: .normal)
        
        
        self.actionView.addSubview(optionView)
        self.actionView.backgroundColor = UIColor.clear
        self.view.addSubview(self.actionView)
        
        
        
        
        optionView.doActionForSecondOption = {
            
            self.removeActionView()
            
            if self.earnItChildUser.earnItTasks.count > 0{
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let parentDashBoardCheckin = storyBoard.instantiateViewController(withIdentifier: "parentDashBoard") as! ParentDashBoard
                parentDashBoardCheckin.prepareData(earnItChildUserForParent: self.earnItChildUser, earnItChildUsers: self.earnItChildUsers)
                let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                
                let slideMenuController  = SlideMenuViewController(mainViewController: parentDashBoardCheckin, leftMenuViewController: optionViewControllerPD)
                
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                slideMenuController.delegate = parentDashBoardCheckin
                self.present(slideMenuController, animated:false, completion:nil)
                
                
            }else {
                
                
                self.view.makeToast("No task available")
            }
            
        }
        
        optionView.doActionForFirstOption = {
            
            self.removeActionView()
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let taskViewController = storyBoard.instantiateViewController(withIdentifier: "TaskView") as! TaskViewController
            taskViewController.earnItChildUserId = self.earnItChildUser.childUserId
            taskViewController.earnItChildUsers = self.earnItChildUsers
            self.present(taskViewController, animated:false, completion:nil)
            
        }
        
        optionView.doActionForFifthOption = {
            
            self.removeActionView()
            print("self.selectedChildUser");

            getGoalsForChild(childId : self.earnItChildUser.childUserId,success: {
                (earnItGoalList) ->() in
                
                //print("GOAL", earnItGoalList.count);
                // print(earnItGoalList);
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let goalViewController = storyBoard.instantiateViewController(withIdentifier: "GoalViewController") as! GoalViewController
                
                if(self.earnItChildUser.earnItGoal.name == "" || self.earnItChildUser.earnItGoal.name == nil){
                    
                    goalViewController.IS_ADD=true
                }else {
                    
                    goalViewController.IS_ADD=false
                }
                
                goalViewController.earnItChildUser = self.earnItChildUser
                goalViewController.earnItChildUsers = self.earnItChildUsers
                self.present(goalViewController, animated:true, completion:nil)
                
                
            })
            { (error) -> () in
                
                let alert = showAlertWithOption(title: "Opps, Please try it again later.", message: "")
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
        
        optionView.doActionForFourthOption = {
            
            self.removeActionView()
            
        }
        
        optionView.doActionForThirdOption = {
            
            self.removeActionView()
            
            var hasPendingTask = false
            
            for pendingTask in self.earnItChildUser.earnItTasks {
                
                if pendingTask.status == TaskStatus.completed{
                    
                    hasPendingTask = true
                    break
                    
                }else {
                    
                    continue
                }
            }
            
            if hasPendingTask == false {
                
                self.view.makeToast("There are no tasks for approval")
                //            let alert = showAlert(title: "", message: "There are no tasks for approval")
                //            self.present(alert, animated: true, completion: nil)
                
            }else {
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let pendingTasksScreen = storyBoard.instantiateViewController(withIdentifier: "PendingTasksScreen") as! PendingTasksScreen
                pendingTasksScreen.prepareData(earnItChildUserForParent: self.earnItChildUser, earnItChildUsers: self.earnItChildUsers)
                let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                let slideMenuController  = SlideMenuViewController(mainViewController: pendingTasksScreen, leftMenuViewController: optionViewControllerPD)
                slideMenuController.automaticallyAdjustsScrollViewInsets = true
                //slideMenuController.delegate = pendingTasksScreen
                self.present(slideMenuController, animated:false, completion:nil)
                
            }
            
            
        }
        
        optionView.doActionForSixthOption = {
            
            self.removeActionView()
            
            let messageContainerView = UIView()
            messageContainerView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
            messageContainerView.backgroundColor = UIColor.clear
            self.messageView.messageText.text = ""
            messageContainerView.addSubview(self.messageView)
            self.view.addSubview(messageContainerView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.messageContainerDidTap(_:)))
            tap.delegate = self
            messageContainerView.addGestureRecognizer(tap)
            
            self.messageView.dissmissMe = {
                
                self.messageView.removeFromSuperview()
                messageContainerView.removeFromSuperview()
                //self.enableBackgroundView()
                
            }
            
            self.messageView.callControllerForSendMessage = {
                
                self.showLoadingView()
                self.messageView.activityIndicator.startAnimating()
                if self.messageView.messageText.text.characters.count == 0 || self.messageView.messageText.text.isEmptyField == true{
                    
                    self.view.endEditing(true)
                    self.view.makeToast("Please enter a message")
                    self.hideLoadingView()
                    self.messageView.activityIndicator.stopAnimating()
                    //                let alert = showAlert(title: "", message: "Please enter a message")
                    //                self.present(alert, animated: true, completion: nil)
                    
                }else {
                    
                    
                    callUpdateApiForChild(firstName: self.earnItChildUser.firstName,childEmail: self.earnItChildUser.email,childPassword: self.earnItChildUser.password,childAvatar: self.earnItChildUser.childUserImageUrl!,createDate: self.earnItChildUser.createDate,childUserId: self.earnItChildUser.childUserId, childuserAccountId: self.earnItChildUser.childAccountId,phoneNumber: self.earnItChildUser.phoneNumber,fcmKey : self.earnItChildUser.fcmToken, message: self.messageView.messageText.text, success: {
                        
                        (childUdateInfo) ->() in
                        
                        createEarnItAppChildUser( success: {
                            
                            (earnItChildUsers) -> () in
                            
                            EarnItAccount.currentUser.earnItChildUsers = earnItChildUsers
                            self.hideLoadingView()
                            self.messageView.activityIndicator.stopAnimating()
                            self.messageView.removeFromSuperview()
                            messageContainerView.removeFromSuperview()
                            
                        }) {  (error) -> () in
                            
                            print("error")
                            
                        }
                        
                    }) { (error) -> () in
                        self.hideLoadingView()
                        self.messageView.activityIndicator.stopAnimating()
                        self.view.makeToast("Send Message Failed")
                        
                        
                        //                let alert = showAlert(title: "Error", message: "Update Child Failed")
                        //                self.present(alert, animated: true, completion: nil)
                        print(" Set status completed failed")
                    }
                    
                }
                
            }
            
            var dView:[String:UIView] = [:]
            dView["MessageView"] = self.messageView
            
            let h_Pin = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(36)-[MessageView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0) , metrics: nil, views: dView)
            self.view.addConstraints(h_Pin)
            
            let v_Pin = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(36)-[MessageView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dView)
            self.view.addConstraints(v_Pin)
            
            self.constY = NSLayoutConstraint(item: self.messageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            self.view.addConstraint(self.constY!)
            
            
            self.constX = NSLayoutConstraint(item: self.messageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            self.view.addConstraint(self.constX!)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.50, options: UIViewAnimationOptions.layoutSubviews, animations: { () -> Void in
                self.messageView.alpha = 1
                
                self.view.layoutIfNeeded()
            }) { (value:Bool) -> Void in
                
            }
            
          }
            
        }
        
    }
    
    func actionViewDidTapped(_ sender: UITapGestureRecognizer){
        print("actionViewDidTapped..")
        self.removeActionView()
        
    }
    
    
    func removeActionView(){
        
        for view in self.actionView.subviews {
            
            view.removeFromSuperview()
        }
        self.actionView.removeFromSuperview()
        
    }
    
    func messageContainerDidTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
    
    
    
}
