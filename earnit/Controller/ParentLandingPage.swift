//
//  ParentLandingPage.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesome_swift
import SlideMenuControllerSwift
import CircleMenu
import KeychainSwift

class ParentLandingPage: UIViewController,UITableViewDelegate, UITableViewDataSource,CircleMenuDelegate,UITextViewDelegate,UIGestureRecognizerDelegate {

    @IBOutlet var childUserTable: UITableView!
    @IBOutlet var tipsContainer: UIView!
    @IBOutlet var tipsButton: UIButton!
    @IBOutlet var welcomLabel: UILabel!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var actionView = UIView()
    
    var yValue : CGFloat = 100.0
    var constX:NSLayoutConstraint?
    var constY:NSLayoutConstraint?
    
    var earnItChildUsers = [EarnItChildUser]()
    var topThreeTasks = [EarnItTask]()
    var selectedChildUser = EarnItChildUser()
    var blurEffectView = UIVisualEffectView()
    var messageView = MessageView()
    //keyboardOffset
    var currentKeyboardOffset : CGFloat = 0.0

    
    let actionItems: [(icon: UIImage, color: UIColor)] = [
        (EarnItImage.setEarnItAddIcon(), UIColor.white),
        (EarnItImage.setEarnItPageIcon(), UIColor.white),
        (EarnItImage.setEarnItPageIcon(), UIColor.white),
        (EarnItImage.setEarnItGoalIcon(), UIColor.white),
        (EarnItImage.setEarnItCommentIcon(), UIColor.white),
        (EarnItImage.setEarnItGoalIcon(), UIColor.white),
        (EarnItImage.setEarnItAppShowTaskIcon(), UIColor.white),
        (EarnItImage.setEarnItPageIcon(), UIColor.white),
        (EarnItImage.setEarnItGoalIcon(), UIColor.white),
        (EarnItImage.setEarnItCommentIcon(), UIColor.white),

        ]
   
    
       //override
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewDidLoad")
        
        print("Parent Landing view did load")
        self.actionView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
        self.actionView.addGestureRecognizer(tapGesture)
        
        self.messageView = (Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?[0] as? MessageView)!
     
        //self.view.addSubview(actionView)
        self.showLoadingView()
        self.requestObserver()
        
        self.childUserTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    
    
    @IBAction func openSideMenu(_ sender: Any) {
        
         
         self.openLeft()
        
    }
    
    //override
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //override
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        if self.earnItChildUsers[section].earnItPendingApprovalTasks.count > 3 || self.earnItChildUsers[section].earnItTopThreePendingApprovalTask.count == 0{
            
            numberOfRows = self.earnItChildUsers[section].earnItTopThreePendingApprovalTask.count + 2
        }else {
            
            numberOfRows = self.earnItChildUsers[section].earnItTopThreePendingApprovalTask.count + 1
        }
        return  numberOfRows

    }
    
    //override
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //print("cellForRowAt")
      
        var taskCell = self.childUserTable.dequeueReusableCell(withIdentifier: "childTaskCellForParent", for: indexPath as IndexPath) as! ChildTaskCellForParent

        //taskCell.addTaskButton.isHidden = false
        taskCell.taskTime.isHidden = false
        taskCell.taskName.isHidden = false
        taskCell.moreButton.isHidden = false
        
        taskCell.taskName?.font = FontHelper.EarnItAppLabelFont()
        
        if indexPath.row == 0{
        
            taskCell.taskName?.text = "Pending Approval:"
            taskCell.taskTime.isHidden = true
            //taskCell.addTaskButton.isHidden = true
            taskCell.taskName.isHidden = false
            taskCell.moreButton.isHidden = true
            taskCell.taskName?.font = FontHelper.earnItAppTopThreeTaskLabelFont()
            return taskCell
            
        }else if (indexPath.row ==  self.earnItChildUsers[indexPath.section].earnItTopThreePendingApprovalTask.count + 1){
            
            taskCell.taskTime.isHidden = true
            taskCell.taskName.isHidden = false
            taskCell.moreButton.isHidden = true

            if self.earnItChildUsers[indexPath.section].earnItPendingApprovalTasks.count == 0 {
                
              taskCell.taskName.text = "None"
            
            }else if self.earnItChildUsers[indexPath.section].earnItPendingApprovalTasks.count  <= 3{
                
                taskCell.taskName.text = ""
                
            }else  {
                
                taskCell.moreButton.isHidden = false
                taskCell.taskName.isHidden = true
                taskCell.showAllPendingTaskScreen = {
                    
                    print("more button clicked")
                    
                    self.selectedChildUser = self.earnItChildUsers[indexPath.section]
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                    let pendingTasksScreen = storyBoard.instantiateViewController(withIdentifier: "PendingTasksScreen") as! PendingTasksScreen
                    pendingTasksScreen.prepareData(earnItChildUserForParent: self.selectedChildUser, earnItChildUsers: self.earnItChildUsers)
                    let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                    
                    let slideMenuController  = SlideMenuViewController(mainViewController: pendingTasksScreen, leftMenuViewController: optionViewControllerPD)
                    
                    slideMenuController.automaticallyAdjustsScrollViewInsets = true
                    //slideMenuController.delegate = pendingTasksScreen
                    self.present(slideMenuController, animated:false, completion:nil)
                    
                    
                }
                //taskCell.taskName.text = "More..."
            }
            return taskCell
            
        }else{
            
            for view in taskCell.subviews{
                
                if view.tag == 1 {
                view.removeFromSuperview()
                }
            }

            taskCell.taskName.isHidden = false
            taskCell.taskTime.isHidden = false
            taskCell.moreButton.isHidden = true
            taskCell.taskName?.text = self.earnItChildUsers[indexPath.section].earnItTopThreePendingApprovalTask[indexPath.row-1].taskName
            taskCell.taskTime.text = self.earnItChildUsers[indexPath.section].earnItTopThreePendingApprovalTask[indexPath.row-1].dueTime
    
            return taskCell
        }
    
    }
    
    //override
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.earnItChildUsers.count
    }
    
    //ovrride
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view  = Bundle.main.loadNibNamed("ChildUserHeaderView", owner: nil, options: nil)?.first as! ChildUserHeaderView

          view.childUserName.text = self.earnItChildUsers[section].firstName
          view.checkInImage.loadImageUsingCache(withUrl: self.earnItChildUsers[section].childUserImageUrl!)
        
          view.showActionButton = {
            
//            let checkInButtonFrame = view.checkInButton.superview?.convert(view.checkInButton.frame, to: self.view)
//            let actionButton = CircleMenu(
//                frame: CGRect(x: (checkInButtonFrame?.origin.x)! - 10, y: (checkInButtonFrame?.origin.y)! , width: 94, height: 50),
//                normalIcon:"icon_menu",
//                selectedIcon:"icon_close",
//                buttonsCount: 8,
//                duration: 0.5,
//                distance: 120)
//            
//            let checkInImageFrame = view.checkInImage.superview?.convert(view.checkInImage.frame, to: self.view)
//            let actionImage = UIImageView()
//            actionImage.frame  = CGRect(x: (checkInImageFrame?.origin.x)!, y: (checkInImageFrame?.origin.y)! , width: 60, height: 60)
//            actionImage.clipsToBounds = true
//            actionImage.layer.cornerRadius = 30
//            actionImage.layer.borderColor = UIColor.white.cgColor
//            actionImage.layer.borderWidth = 2
//            actionImage.contentMode = .scaleAspectFill
//            actionImage.backgroundColor = UIColor.white
//            actionImage.image = view.checkInImage.image
//            self.actionView.addSubview(actionImage)
//            actionButton.delegate = self
//            actionButton.layer.cornerRadius = actionButton.frame.size.width / 2.0
//            actionButton.setImage(nil, for: .normal)
//            self.selectedChildUser = self.earnItChildUsers[section]
//            actionButton.isUserInteractionEnabled = false
//            self.actionView.addSubview(actionButton)
//            self.actionView.backgroundColor = UIColor.clear
//            actionButton.sendActions(for: .touchUpInside)
//            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
//            self.blurEffectView = UIVisualEffectView(effect: blurEffect)
//            self.blurEffectView.frame = self.view.bounds
//            self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            self.view.addSubview(self.blurEffectView)
//            self.blurEffectView.addSubview(self.actionView)
            
            
            let optionView  = (Bundle.main.loadNibNamed("OptionView", owner: self, options: nil)?[0] as? OptionView)!
            optionView.center = self.view.center
            
            let checkInImageFrame = view.checkInImage.superview?.convert(view.checkInImage.frame, to: self.view)
            optionView.frame.origin.y = (checkInImageFrame?.origin.y)!
            optionView.frame.origin.x = (checkInImageFrame?.origin.x)! - 120
            
            let visibleRect = optionView.frame.intersection(self.view.bounds)
            
            
             optionView.frame.origin.y = (checkInImageFrame?.origin.y)! - (optionView.frame.size.height - visibleRect.size.height)
            
            self.selectedChildUser = self.earnItChildUsers[section]
            
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
            optionView.userImageView.image = view.checkInImage.image
            self.actionView.addSubview(optionView)
            self.actionView.backgroundColor = UIColor.clear
            self.view.addSubview(self.actionView)
            
            getGoalsForChild(childId : self.selectedChildUser.childUserId,success: {
                
                (earnItGoalList) ->() in
                
                for earnItGoal in  earnItGoalList {
                    
                    self.selectedChildUser.earnItGoal = earnItGoal
                }
            })
                
            { (error) -> () in
                
                //self.view.makeToast("Get goal list failed")
            }
            
            optionView.doActionForFirstOption = {
                
                self.removeActionView()
                self.goToAddTaskScreen()
          
            }
            
            optionView.doActionForSecondOption = {
                
                self.removeActionView()
                self.goToCheckInScreen()
                
            }
            
            optionView.doActionForThirdOption = {
                
              self.removeActionView()
              self.goToPendingApprovalPage()
                
            }
            
            optionView.doActionForFourthOption = {
                
                self.removeActionView()
                self.goToBalanceScreen()
                print("open balance screen")
                
            }
            
            
            optionView.doActionForFifthOption = {
                
                self.removeActionView()
                self.goToAddGoalPage()
            }
            
            optionView.doActionForSixthOption = {
                
                self.removeActionView()
                self.goToMessageScreen()
            }

        }
        
        //yValue = yValue + 100
        return view

    }
    
   
    
    //override
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            return 40
        }else if indexPath.row ==  self.earnItChildUsers[indexPath.section].earnItTopThreePendingApprovalTask.count + 1 {
            
            return 55
        }else{
            
            return 40
        }
    }
    
    func showLoadingView(){
        
        self.view.alpha = 0.7
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
    }
    
    
    func hideLoadingView(){
        
        self.view.alpha = 1
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("Parent Landing view did appear")
        createEarnItAppChildUser( success: {
            
            (earnItChildUsers) -> () in
            
            EarnItAccount.currentUser.earnItChildUsers = earnItChildUsers
            self.earnItChildUsers = EarnItAccount.currentUser.earnItChildUsers
            self.childUserTable.reloadData()
            self.hideLoadingView()
            
            
        }) {  (error) -> () in
            
            print("error")
            
        }
        
        self.childUserTable.reloadData()
        self.welcomLabel.text = "Hi" + " " + EarnItAccount.currentUser.firstName
        
        _ = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.fetchParentUserDetailFromBackground), userInfo: nil, repeats: true)
        
        _ = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.fetchChildUserDetailFromBackground), userInfo: nil, repeats: true)
      
    }
    
    
    // configure buttons
     func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int){
    
        button.backgroundColor = UIColor.clear
        button.setImage(actionItems[atIndex].icon, for: .normal)
        button.imageView?.layer.cornerRadius = (button.imageView?.frame.width)! / 2
        button.imageView?.backgroundColor = UIColor.clear
        button.addTarget(self, action:#selector(handleRegister(_:)), for: .touchUpInside)
        button.tag = atIndex
        //let highlightedImage  = actionItems[atIndex].icon.withRenderingMode(.alwaysTemplate)
        //button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        button.titleLabel?.font = FontHelper.earnItAppIconTextFont()
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.earnItAppPinkColor(), for: .normal)
        button.backgroundColor = UIColor.clear
        button.titleEdgeInsets = UIEdgeInsetsMake(0,5,0,0)
        
        switch atIndex {
           
        case 4 :
            
           
            button.setTitle("Message", for: .normal)
            
            break
        case 5 :

            button.setTitle("Goals", for: .normal)
            break
        case 6 :

            button.setTitle("Approve Tasks", for: .normal)
            break
        case 7 :

            button.setTitle("All Tasks", for: .normal)
            break
        case 0 :

            button.setTitle("Add Task", for: .normal)
            break
        default:
            break
            
        }

        if atIndex == 1 || atIndex == 2 || atIndex == 3{
            
            button.backgroundColor = UIColor.clear
            button.setImage(nil, for: .normal)
            
        }

       
    }
    
    // call before animation
     func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int){
        
        
    }
    
    // call after animation
     func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int){
        
        print("button did select")
    }
    
    // call upon cancel of the menu
     func menuCollapsed(_ circleMenu: CircleMenu){
        
    }

    func handleRegister(_ sender : UIButton){
        
        self.removeActionView()
        switch sender.tag {
            
        case 4 :
            
            self.goToMessageScreen()

            break
        case 5 :
            self.goToAddGoalPage()
            break
        case 6 :
            self.goToPendingApprovalPage()
            break
        case 7 :
            self.goToCheckInScreen()
            break
        case 0 :
            self.goToAddTaskScreen()
            break
        default:
            break
            
        }
        
        print("handle register")
        
        print("tapped\(sender.tag) for child ) ")
       
    }
    
    
    
    func messageContainerDidTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func goToMessageScreen(){
        
        self.removeActionView()
        let messageContainerView = UIView()
        messageContainerView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        messageContainerView.backgroundColor = UIColor.clear
        messageView.messageText.text = ""
        messageContainerView.addSubview(messageView)
        self.view.addSubview(messageContainerView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.messageContainerDidTap(_:)))
        tap.delegate = self
        messageContainerView.addGestureRecognizer(tap)
        
        self.messageView.messageToLabel.text = "Message to  \(self.selectedChildUser.firstName!):"
        self.messageView.center = CGPoint(x: self.view.center.x,y :self.view.center.y-80)
        self.messageView.messageText.becomeFirstResponder()
        self.messageView.messageText.delegate = self
        self.messageView.messageText.becomeFirstResponder()
        
        messageView.dissmissMe = {
            
            self.messageView.removeFromSuperview()
            messageContainerView.removeFromSuperview()
            //self.enableBackgroundView()
            
        }
        
        messageView.callControllerForSendMessage = {
            
            if self.messageView.messageText.text.characters.count == 0 || self.messageView.messageText.text.isEmptyField == true{
                
                self.view.endEditing(true)
                self.view.makeToast("Please enter a message")
                
//                let alert = showAlert(title: "", message: "Please enter a message")
//         e       self.present(alert, animated: true, completion: nil)
                
            }else {
                
                self.showLoadingView()
                self.messageView.activityIndicator.startAnimating()
                callUpdateApiForChild(firstName: self.selectedChildUser.firstName,childEmail: self.selectedChildUser.email,childPassword: self.selectedChildUser.password,childAvatar: self.selectedChildUser.childUserImageUrl!,createDate: self.selectedChildUser.createDate,childUserId: self.selectedChildUser.childUserId, childuserAccountId: self.selectedChildUser.childAccountId,phoneNumber: self.selectedChildUser.phoneNumber,fcmKey : self.selectedChildUser.fcmToken, message: self.messageView.messageText.text, success: {
                    
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
                    //self.enableBackgroundView()
                    
                }) { (error) -> () in
                    self.hideLoadingView()
                    let alert = showAlert(title: "Error", message: "Update Child Failed")
                    self.present(alert, animated: true, completion: nil)
                    print(" Set status completed failed")
                }
                
            }
            
        }
        
        var dView:[String:UIView] = [:]
        dView["MessageView"] = messageView
        
        let h_Pin = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(36)-[MessageView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0) , metrics: nil, views: dView)
        self.view.addConstraints(h_Pin)
        
        let v_Pin = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(36)-[MessageView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dView)
        self.view.addConstraints(v_Pin)
        
        constY = NSLayoutConstraint(item: messageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        self.view.addConstraint(constY!)
        
        
        constX = NSLayoutConstraint(item: messageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        self.view.addConstraint(constX!)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.50, options: UIViewAnimationOptions.layoutSubviews, animations: { () -> Void in
            self.messageView.alpha = 1
            
            
            self.view.layoutIfNeeded()
        }) { (value:Bool) -> Void in
            
        }
        
    }
    
    
    
    func goToBalanceScreen(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let balanceScreen = storyBoard.instantiateViewController(withIdentifier: "BalanceScreen") as! BalanceScreeen
        balanceScreen.earnItChildUsers =  self.earnItChildUsers
        balanceScreen.earnItChildUser = self.selectedChildUser
        print("self.selectedChildUser.earnItGoal.cash! \(self.selectedChildUser.earnItGoal.cash!)")
        print(" self.selectedChildUser.earnItGoal.tally! \( self.selectedChildUser.earnItGoal.tally!)")
        print("self.selectedChildUser.earnItGoal.ammount \( self.selectedChildUser.earnItGoal.ammount!)")
        if (self.selectedChildUser.earnItGoal.cash! + self.selectedChildUser.earnItGoal.tally!  + self.selectedChildUser.earnItGoal.ammount!) == 0 {
            
            self.view.makeToast("No balance to display!!")
            
        }else {
            
            self.present(balanceScreen, animated:true, completion:nil)
        }

    }
    
    
    
    func goToAddGoalPage(){
        
//        let alert = showAlert(title: "", message: "Show add goal screen")
//        self.present(alert, animated: true, completion: nil)
        print("self.selectedChildUser");

        print(self.selectedChildUser);
        getGoalsForChild(childId : self.selectedChildUser.childUserId,success: {
            (earnItGoalList) ->() in
            
            //print("GOAL", earnItGoalList.count);
           // print(earnItGoalList);
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let goalViewController = storyBoard.instantiateViewController(withIdentifier: "GoalViewController") as! GoalViewController
            
            print("earnItGoalList.count>0 \(earnItGoalList.count)")
            if(self.selectedChildUser.earnItGoal.name == "" || self.selectedChildUser.earnItGoal.name == nil){
                
                goalViewController.IS_ADD=true
            }else {
                
                 goalViewController.IS_ADD=false
            }
            
            goalViewController.earnItChildUser = self.selectedChildUser
            goalViewController.earnItChildUsers = self.earnItChildUsers
            self.present(goalViewController, animated:true, completion:nil)


        })
        { (error) -> () in
            
            let alert = showAlertWithOption(title: "Opps, Please try it again later.", message: "")
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }

     
        /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let goalViewController = storyBoard.instantiateViewController(withIdentifier: "GoalViewController") as! GoalViewController
        goalViewController.earnItChildUser = self.selectedChildUser
        self.present(goalViewController, animated:true, completion:nil)*/
    }
    
    func goToCheckInScreen(){
        
     self.showLoadingView()
        
    if self.selectedChildUser.earnItTasks.count == 0{
        
        self.hideLoadingView()
        self.view.makeToast("No task available")
            
    }else {
        
     let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
     let parentDashBoardCheckin = storyBoard.instantiateViewController(withIdentifier: "parentDashBoard") as! ParentDashBoard
     parentDashBoardCheckin.prepareData(earnItChildUserForParent: self.selectedChildUser, earnItChildUsers: self.earnItChildUsers)
     let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
 
     let slideMenuController  = SlideMenuViewController(mainViewController: parentDashBoardCheckin, leftMenuViewController: optionViewControllerPD)
 
     slideMenuController.automaticallyAdjustsScrollViewInsets = true
     slideMenuController.delegate = parentDashBoardCheckin
     self.present(slideMenuController, animated:false, completion:nil)
      
        }
 
    }
 
    func goToPendingApprovalPage(){
 
//        let alert = showAlert(title: "", message: "Show pending approvel task screen")
//        self.present(alert, animated: true, completion: nil)
        
        var hasPendingTask = false
        
        for pendingTask in self.selectedChildUser.earnItTasks {
            
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
        pendingTasksScreen.prepareData(earnItChildUserForParent: self.selectedChildUser, earnItChildUsers: self.earnItChildUsers)
        let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
        let slideMenuController  = SlideMenuViewController(mainViewController: pendingTasksScreen, leftMenuViewController: optionViewControllerPD)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        //slideMenuController.delegate = pendingTasksScreen
        self.present(slideMenuController, animated:false, completion:nil)
            
        }
            
    }
    
    func goToAddTaskScreen(){
        
        //self.showLoadingView()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let taskViewController = storyBoard.instantiateViewController(withIdentifier: "TaskView") as! TaskViewController
        taskViewController.earnItChildUserId = self.selectedChildUser.childUserId
        taskViewController.earnItChildUsers = self.earnItChildUsers
        self.present(taskViewController, animated:true, completion:nil)
        
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
        self.blurEffectView.removeFromSuperview()
        
    }
    
    
    
    
    func fetchParentUserDetailFromBackground(){
        
            DispatchQueue.global().async {
                
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
                    
//                    let alert = showAlertWithOption(title: "", message: "Login failed")
//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreenToLogin))
//                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                DispatchQueue.main.async {
                    
                    print("done calling background fetch....")
                    
                    if EarnItAccount.currentUser.firstName != nil{
                        
                         self.welcomLabel.text = "Hi" + " " + EarnItAccount.currentUser.firstName
                    }
                    
                }
            
          }
    }
    
    
    
    func dismissScreenToLogin(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
        self.present(loginController, animated: true, completion: nil)
        
    }
    
    
   func fetchChildUserDetailFromBackground(){
        
        DispatchQueue.global().async {
            
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
                
                self.earnItChildUsers = earnItChildUsers
                self.childUserTable.reloadData()
                self.hideLoadingView()
                
                
            }) {  (error) -> () in
                
                print("error")
                
            }
            
            DispatchQueue.main.async {
                
                print("done background processing for checking screen")
                if self.earnItChildUsers.count > 0 {
                    
                        self.childUserTable.reloadData()
                }
            
            }
        }
        
    }
    
    
    
    
    // MARK: - NonSpecific User Functions
    
    /**
     Creates request for keyboardWillShow
     
     - Parameters:
     
     - nil
     */
    
    private func requestObserver(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardDidHide  , object: nil)
        
    }
    
    
    /**
     Responds to keyboard showing and adjusts the scrollview.
     
     :param: notification
     Type - NSNotification
     */
    
    func keyboardWillShow(_ notification:NSNotification){
        
        let info = notification.userInfo!
        let keyboardHeight: CGFloat = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            
            switch UIScreen.main.nativeBounds.height {
                
            case 2208:
                
                let keyboardYValue = self.view.frame.height - keyboardHeight
                
                
                if self.messageView.messageText.isFirstResponder {
                    
                    let commentYValue = self.messageView.messageText.frame.size.height + self.messageView.messageText.frame.origin.y
                    
                    if self.currentKeyboardOffset == 0.0 {
                        
                        if (commentYValue ) > keyboardYValue - 20.0 {
                            
                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - commentYValue + 100
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.view.frame.origin.y -= self.currentKeyboardOffset
                                
                            }, completion: { (completed) -> Void in
                                
                                
                            })
                            
                        }
                        
                    }
                    
                    
                }
                
            default:
                
                
                let keyboardYValue = self.view.frame.height - keyboardHeight
                
                
                if self.messageView.messageText.isFirstResponder {
                    
                    print("message text is first responseder")
                    let commentYValue = self.messageView.messageText.frame.size.height + self.messageView.messageText.frame.origin.y
                    
                    if self.currentKeyboardOffset == 0.0 {
                        
                        if (commentYValue ) > keyboardYValue + 10.0 {
                            
                            self.currentKeyboardOffset = (keyboardYValue + 50.0) - commentYValue + 160
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.view.frame.origin.y -= self.currentKeyboardOffset
                                
                            }, completion: { (completed) -> Void in
                                
                                
                            })
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    
    /**
     Responds to keyboard hiding and adjusts the scrollview.
     
     :param: notification
     Type - NSNotification
     */
    
    func keyboardWillHide(_ notification:NSNotification){
        
        
        let keyboardOffset : CGFloat = rePostionView(currentOffset: self.currentKeyboardOffset)
        self.view.frame.origin.y = keyboardOffset
        self.currentKeyboardOffset = keyboardOffset
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("table cell was selected...")
        print("more button clicked")
        
        if  self.earnItChildUsers[indexPath.section].earnItPendingApprovalTasks.count == 0 ||  indexPath.row == 0 {
            
            
        }else {
            
            self.selectedChildUser = self.earnItChildUsers[indexPath.section]
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let pendingTasksScreen = storyBoard.instantiateViewController(withIdentifier: "PendingTasksScreen") as! PendingTasksScreen
            pendingTasksScreen.prepareData(earnItChildUserForParent: self.selectedChildUser, earnItChildUsers: self.earnItChildUsers)
            let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
            
            let slideMenuController  = SlideMenuViewController(mainViewController: pendingTasksScreen, leftMenuViewController: optionViewControllerPD)
            
            slideMenuController.automaticallyAdjustsScrollViewInsets = true
            //slideMenuController.delegate = pendingTasksScreen
            self.present(slideMenuController, animated:false, completion:nil)
            
        }
        
    }

 
    

}



