//
//  PendingTasksScreen.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/30/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import Material
import KeychainSwift

class PendingTasksScreen : UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextViewDelegate{
    
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var welcomText: UILabel!
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var childTableForTodayTask: UITableView!
    @IBOutlet var showAllView: UIView!
    @IBOutlet var showAllButton2: UIButton!
    @IBOutlet var showAddTask: UIButton!
    @IBOutlet var showSideMenuButton: UIButton!
    @IBOutlet var goalName: UILabel!
    @IBOutlet var earnedForAGoal: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var taskApprovalView =  TaskApprovalView()
    var messageView = MessageView()
    var completedTask = EarnItTask()
    var constX:NSLayoutConstraint?
    var constY:NSLayoutConstraint?
    
    
    var showAll = false
    var showAllClicked = false
    var dayTasks = [DayTask]()
    var earnItChildUserForParent : EarnItChildUser!
    var earnItChildUsers = [EarnItChildUser]()
    var overdueTasks = [EarnItTask]()
    var actionView = UIView()
    
    
    //keyboardOffset
    var currentKeyboardOffset : CGFloat = 0.0
    
    struct TappedSectionDetails {
        var sectionNo = 0
        var isCollapsed = false
        
    }
    
    var SectionDetailsArray = [TappedSectionDetails]()
    
    //var tasksForToday = [EarnItTask]()
    
    func prepareData(earnItChildUserForParent: EarnItChildUser, earnItChildUsers: [EarnItChildUser]) {
        self.earnItChildUserForParent = earnItChildUserForParent
        self.earnItChildUsers = earnItChildUsers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.actionView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
        self.actionView.addGestureRecognizer(tapGesture)
        self.taskApprovalView = (Bundle.main.loadNibNamed("TaskApprovalView", owner: self, options: nil)?[0] as? TaskApprovalView)!
        self.taskApprovalView.frame.size.width = self.view.frame.width - 40
        self.taskApprovalView.frame.size.height = self.view.frame.height - 40
        self.taskApprovalView.comments.delegate = self
        self.taskApprovalView.center = self.view.center
        
        self.messageView = (Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?[0] as? MessageView)!
        self.messageView.messageToLabel.text = "Message to  \(self.earnItChildUserForParent.firstName!):"
        self.messageView.center = self.view.center
        self.messageView.messageText.delegate = self
        
        
        self.welcomText.text = self.earnItChildUserForParent.firstName.appending("'s Tasks")
        
        self.childTableForTodayTask.register(UINib(nibName: "ChildTaskDetailApprovalCell", bundle: nil), forCellReuseIdentifier: "ChildTaskDetailApprovalCell")
        
        self.childTableForTodayTask.delegate = self
        self.requestObserver()
        var tasks = earnItChildUserForParent.earnItTasks
        for daytask in earnItChildUserForParent.earnItTasks{
            
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.ReferenceType.local
            formatter.dateFormat = "M/dd"
            let currentDay = formatter.string(from: currentDate as Date)
            
            
            if  currentDay != daytask.dateMonthString  {
                
                if currentDate < daytask.dueDate {
                    
                    tasks.remove(at: tasks.index(of: daytask)!)
                    
                }
                
            }
            
        }
        
        var taskForDaysTask = [EarnItTask]()
        var taskForOverdueTasks = [EarnItTask]()
        
        for task in tasks {
            
            if task.status  == TaskStatus.completed {
                
                taskForDaysTask.append(task)
            }
        }
        
        for task in earnItChildUserForParent.earnItTasks {
            
            if task.status == TaskStatus.completed {
                
                taskForOverdueTasks.append(task)
            }
        }
     
        self.dayTasks = getDayTaskListForParent(earnItTasks: taskForDaysTask)
        self.overdueTasks = getOverDueTaskListForParent(earnItTasks: taskForOverdueTasks)
        //self.sendMessageButton.setTitle("Send a message to  " + self.earnItChildUserForParent.firstName, for: .normal)
        
        self.childTableForTodayTask.reloadData()
        self.userImageView.loadImageUsingCache(withUrl: self.earnItChildUserForParent.childUserImageUrl )
        self.childTableForTodayTask.tableFooterView = UIView()
        self.taskApprovalView.removeFromSuperview()
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        var numberOfRows = 1
        
        if self.overdueTasks.count > 0{
            
            if section == 0{
                
                numberOfRows = self.overdueTasks.count
                
            }else {
                
                numberOfRows = self.dayTasks[section-1].earnItTasks.count
                
            }
            
        }else {
            
            print("number of rows \(numberOfRows)")
            numberOfRows = self.dayTasks[section].earnItTasks.count
            
        }
        
        if SectionDetailsArray[section].isCollapsed {
            return 0
            
        }
            
        else {
            
            return numberOfRows
        }
    }
    
    
    //override
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let taskCell = self.childTableForTodayTask.dequeueReusableCell(withIdentifier: "ChildTaskDetailApprovalCell", for: indexPath as IndexPath) as! ChildTaskDetailApprovalCell
        
        if self.overdueTasks.count > 0{
            
            if (indexPath.section == 0 ){
                
                taskCell.taskName.text = self.overdueTasks[indexPath.row].taskName
                taskCell.taskDescription.text = self.self.overdueTasks[indexPath.row].dateMonthString + " @ " + self.overdueTasks[indexPath.row].dueTime
                
                taskCell.statusImage.backgroundColor = getColorStatusForTaskForParentDashBoard(earnItTask: self.overdueTasks[indexPath.row])
                
                if (self.overdueTasks[indexPath.row].status == TaskStatus.completed){
                    
                    taskCell.approveButton.isHidden = false
                    taskCell.approveButton.isUserInteractionEnabled = true
                    taskCell.approveButton.setImage(EarnItImage.setEarnItAppShowTaskImage(), for: .normal)
                    taskCell.askToApproveTheCompletedTask = {
                        
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let taskApprovalScreen  = storyBoard.instantiateViewController(withIdentifier: "TaskApprovalScreen") as! TaskApprovalScreen
                        taskApprovalScreen.completedTask =  self.overdueTasks[indexPath.row]
                        taskApprovalScreen.earnItChildUserForParent = self.earnItChildUserForParent
                        self.present(taskApprovalScreen, animated:true, completion:nil)
                        
                    }
                    
                }else {
                    
                    taskCell.approveButton.isHidden = true
                    taskCell.approveButton.isUserInteractionEnabled = false
                }
                
                
            }else {
                
                taskCell.taskName.text = self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row].taskName
                taskCell.taskDescription.text = self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row].dateMonthString + " @ " + self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row].dueTime
                taskCell.statusImage.backgroundColor = getColorStatusForTaskForParentDashBoard(earnItTask: self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row])
                
                if (self.dayTasks[indexPath.section - 1 ].earnItTasks[indexPath.row].status == TaskStatus.completed){
                    
                    taskCell.approveButton.isHidden = false
                    taskCell.approveButton.isUserInteractionEnabled = true
                    taskCell.approveButton.setImage(EarnItImage.setEarnItAppShowTaskImage(), for: .normal)
                    
                    taskCell.askToApproveTheCompletedTask = {
                        
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let taskApprovalScreen  = storyBoard.instantiateViewController(withIdentifier: "TaskApprovalScreen") as! TaskApprovalScreen
                        taskApprovalScreen.completedTask =  self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row]
                        taskApprovalScreen.earnItChildUserForParent = self.earnItChildUserForParent
                        self.present(taskApprovalScreen, animated:true, completion:nil)
                        
                    }
                    
                }else {
                    
                    taskCell.approveButton.isHidden = true
                    taskCell.approveButton.isUserInteractionEnabled = false
                    
                }
                
            }
            
        }else {
            
            taskCell.taskName.text = self.dayTasks[indexPath.section].earnItTasks[indexPath.row].taskName
            taskCell.taskDescription.text = self.dayTasks[indexPath.section].earnItTasks[indexPath.row].dateMonthString + " @ " + self.dayTasks[indexPath.section].earnItTasks[indexPath.row].dueTime
            
            taskCell.statusImage.backgroundColor = getColorStatusForTaskForParentDashBoard(earnItTask: self.dayTasks[indexPath.section].earnItTasks[indexPath.row])
            
            if (self.dayTasks[indexPath.section].earnItTasks[indexPath.row].status == TaskStatus.completed){
                
                taskCell.approveButton.isHidden = false
                taskCell.approveButton.isUserInteractionEnabled = true
                taskCell.approveButton.setImage(EarnItImage.setEarnItAppShowTaskImage(), for: .normal)
                
                taskCell.askToApproveTheCompletedTask = {
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let taskApprovalScreen  = storyBoard.instantiateViewController(withIdentifier: "TaskApprovalScreen") as! TaskApprovalScreen
                    taskApprovalScreen.completedTask =  self.dayTasks[indexPath.section].earnItTasks[indexPath.row]
                    taskApprovalScreen.earnItChildUserForParent = self.earnItChildUserForParent
                    self.present(taskApprovalScreen, animated:true, completion:nil)
                    
                }
                
            }else {
                
                taskCell.approveButton.isHidden = true
                taskCell.approveButton.isUserInteractionEnabled = false
                
            }
            
        }
        
        return taskCell
    }
    
    
    
    //override
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSectiontoReturn  = 0
        
        if showAll == false{
            
            if self.overdueTasks.count > 0 || self.dayTasks.count > 0 {
                
                numberOfSectiontoReturn = 1
                
            }
            
        }else {
            
            var totalCompletedTaskCount = 0
            
            for task in self.earnItChildUserForParent.earnItTasks {
                
                if task.status == TaskStatus.completed {
                    
                    totalCompletedTaskCount = totalCompletedTaskCount + 1
                }
            }
            
            
            if (self.overdueTasks.count + self.dayTasks.count  ==
                totalCompletedTaskCount) && showAllClicked {
                showAllClicked = false
                print("no more task available")
                self.view.makeToast("No more task available")
            }
            
            if self.overdueTasks.count > 0 {
                
                numberOfSectiontoReturn =  self.dayTasks.count + 1
                
            }else {
                
                numberOfSectiontoReturn =  self.dayTasks.count
            }
            
            
        }
        for i in 0...numberOfSectiontoReturn {
            var sectionDetail = TappedSectionDetails()
            sectionDetail.sectionNo = i
            sectionDetail.isCollapsed = false
            
            SectionDetailsArray.append(sectionDetail)
        }

        
        return numberOfSectiontoReturn
    }
    
    func taskDidTap(recognizer: UISwipeGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.ended {
            let tapLocation = recognizer.location(in: self.childTableForTodayTask)
            if let tapIndexPath = self.childTableForTodayTask.indexPathForRow(at: tapLocation) {
                if let tapCell = self.childTableForTodayTask.cellForRow(at: tapIndexPath) {
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                    let taskViewController = storyBoard.instantiateViewController(withIdentifier: "TaskView") as! TaskViewController
                    taskViewController.earnItChildUserId = self.earnItChildUserForParent.childUserId
                    taskViewController.earnItChildUsers = self.earnItChildUsers
                    taskViewController.isInEditingMode = true
                    
                    if self.overdueTasks.count > 0{
                        
                        if (tapIndexPath.section == 0 ){
                            
                            taskViewController.earnItTaskToEdit = self.overdueTasks[tapIndexPath.row]
                            
                        }else {
                            
                            taskViewController.earnItTaskToEdit  = self.dayTasks[tapIndexPath.section - 1].earnItTasks[tapIndexPath.row]
                            
                        }
                        
                    }
                        
                    else {
                        
                        taskViewController.earnItTaskToEdit = self.dayTasks[tapIndexPath.section].earnItTasks[tapIndexPath.row]
                        
                    }
                    
                    print("TaskStatus \(taskViewController.earnItTaskToEdit.status)")
                    print("TaskStatus \(taskViewController.earnItTaskToEdit.taskName)")
                    
                    
                    if taskViewController.earnItTaskToEdit.status != TaskStatus.completed {
                        self.showLoadingView()
                        let optionViewControllerPLP = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                        
                        let slideMenuController  = SlideMenuViewController(mainViewController: taskViewController, rightMenuViewController: optionViewControllerPLP)
                        
                        slideMenuController.automaticallyAdjustsScrollViewInsets = true
                        slideMenuController.delegate = taskViewController
                        
                        self.present(slideMenuController, animated:false, completion:nil)
                        
                    }
                    
                    else if taskViewController.earnItTaskToEdit.status == TaskStatus.completed {
                        
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let taskApprovalScreen  = storyBoard.instantiateViewController(withIdentifier: "TaskApprovalScreen") as! TaskApprovalScreen
                        taskApprovalScreen.completedTask =  taskViewController.earnItTaskToEdit
                        taskApprovalScreen.earnItChildUserForParent = self.earnItChildUserForParent
                        self.present(taskApprovalScreen, animated:true, completion:nil)
                        
                    }
                    
                }
            }
        }
    }
    
    
    
  
    
    
    //ovrride
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view  = Bundle.main.loadNibNamed("DayHeader", owner: nil, options: nil)?.first as! DayHeader
        view.sectionNo = section

        if self.overdueTasks.count > 0{
            
            if (section == 0){
                
                view.dayDetail.text = "Past Due"
                
            }else if isCurrentDate(earnItTaskDate: self.dayTasks[section - 1].date) {
                
                view.dayDetail.text =  "Today" + " " + self.dayTasks[section - 1].date
                
            }else{
                
                view.dayDetail.text =  self.dayTasks[section - 1].dayName + " " + self.dayTasks[section - 1].date
            }
        }else {
            
            if isCurrentDate(earnItTaskDate: self.dayTasks[section].date) {
                
                view.dayDetail.text =  "Today" + " " + self.dayTasks[section].date
                
            }else{
                
                view.dayDetail.text =  self.dayTasks[section].dayName + " " + self.dayTasks[section].date
            }
            
        }
        
        if !SectionDetailsArray[section].isCollapsed {
            view.arrowLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(sectionDidTap))
        view.addGestureRecognizer(tapRecognizer)
        return view
        
    }
    
    func sectionDidTap(recognizer: UISwipeGestureRecognizer) {
        
        guard let Header = recognizer.view as? DayHeader else {
            return
        }
        
        
        if SectionDetailsArray[Header.sectionNo].isCollapsed {
            SectionDetailsArray[Header.sectionNo].isCollapsed = false
        }
        else {
            SectionDetailsArray[Header.sectionNo].isCollapsed = true
        }
        
        // self.childTableForTodayTask.reloadData()
        self.childTableForTodayTask.reloadSections((NSIndexSet(index: Header.sectionNo) as IndexSet), with: .automatic)
    }

    
    
    //override
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
    //override
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 80
        
    }
    
    
    @IBAction func showAddTaskClicked(_ sender: Any) {
        
        self.view.endEditing(true)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let taskViewController = storyBoard.instantiateViewController(withIdentifier: "TaskView") as! TaskViewController
        taskViewController.earnItChildUserId = self.earnItChildUserForParent.childUserId
        taskViewController.earnItChildUsers = self.earnItChildUsers
        self.present(taskViewController, animated:false, completion:nil)
        
    }
    
    
    @IBAction func showAllButtonClicked(_ sender: Any) {
        
        showAll = true
        showAllClicked = true
        var tasks =  getTodayandFutureTask(earnItTasks: earnItChildUserForParent.earnItTasks)
        var taskForDaysTask = [EarnItTask]()
        var taskForOverdueTasks = [EarnItTask]()
        
        for task in tasks {
            
            if task.status  == TaskStatus.completed {
                
                taskForDaysTask.append(task)
            }
        }
        
        for task in earnItChildUserForParent.earnItTasks {
            
            if task.status == TaskStatus.completed {
                
                taskForOverdueTasks.append(task)
            }
        }
        
        self.dayTasks = getDayTaskListForParent(earnItTasks: taskForDaysTask)
        self.overdueTasks = getOverDueTaskListForParent(earnItTasks: taskForOverdueTasks)
        self.childTableForTodayTask.reloadData()
        
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
    
    
    
    func getGoalListForCurrentUser(){
        
        getGoalsForChild(childId : self.earnItChildUserForParent.childUserId,success: {
            
            (earnItGoalList) ->() in
            
            for earnItGoal in earnItGoalList{
                
                self.earnItChildUserForParent.earnItGoal = earnItGoal
                //self.goalName.text = earnItGoal.name
                //self.earnedForAGoal.text = "$\(earnItGoal.tally!) of $\(earnItGoal.ammount!) earned  \(earnItGoal.tallyPercent!)%"
                
            }
            
            
        })
            
        { (error) -> () in
            
            self.view.makeToast("Get goal list failed ")
//            let alert = showAlertWithOption(title: "Get goal list failed ", message: "")
//            
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            
            
        }
        
        
    }
    
    
    
    func addTapGestureForTaskRow(){
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(taskDidTap))
        tapRecognizer.delegate = self
        self.childTableForTodayTask.addGestureRecognizer(tapRecognizer)
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showLoadingView()
        _ = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.fetchParentUserDetailFromBackground), userInfo: nil, repeats: true)
        
        _ = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.fetchChildUserDetailFromBackground), userInfo: nil, repeats: true)
        
        
        createEarnItAppChildUser( success: {
            
            (earnItChildUsers) -> () in
            
            self.earnItChildUsers = earnItChildUsers
            
            for earnItChildUser in self.earnItChildUsers {
                
                if earnItChildUser.childUserId == self.earnItChildUserForParent.childUserId{
                    
                    self.earnItChildUserForParent.earnItTasks = earnItChildUser.earnItTasks
                    
                    self.reloadChildUserTable()
                    self.getGoalListForCurrentUser()
                    self.addTapGestureForTaskRow()
                    self.hideLoadingView()
                    
                }
                
            }
            
        }) {  (error) -> () in
            
            print("error")
            self.hideLoadingView()
        }
        
    }
    
    
    
    @IBAction func openRight(_ sender: UIButton) {
        
        print("Should Open Slide Menu in checkin")
        self.openLeft()
    }
    
    
    
    
    func  enableBackgroundView(){
        
        //self.sendMessageButton.isUserInteractionEnabled = true
        self.showAddTask.isUserInteractionEnabled = true
        self.showSideMenuButton.isUserInteractionEnabled = true
        self.childTableForTodayTask.isUserInteractionEnabled = true
    }
    
    func  disableBackgroundView(){
        
        //self.sendMessageButton.isUserInteractionEnabled = false
        self.showAddTask.isUserInteractionEnabled = false
        self.showSideMenuButton.isUserInteractionEnabled = false
        self.childTableForTodayTask.isUserInteractionEnabled = false
        
    }
 
    
    
    func reloadChildUserTable(){
        
        
        var tasks =  getTodayandFutureTask(earnItTasks: self.earnItChildUserForParent.earnItTasks)

        var taskForDaysTask = [EarnItTask]()
        var taskForOverdueTasks = [EarnItTask]()
        
        for task in tasks {
            
            if task.status  == TaskStatus.completed {
                
                taskForDaysTask.append(task)
            }
        }
        
        for task in earnItChildUserForParent.earnItTasks {
            
            if task.status == TaskStatus.completed {
                
                taskForOverdueTasks.append(task)
            }
        }
        
        if (taskForOverdueTasks.count == 0 && taskForOverdueTasks.count == 0){
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let parentDashBoardCheckin = storyBoard.instantiateViewController(withIdentifier: "parentDashBoard") as! ParentDashBoard
            parentDashBoardCheckin.prepareData(earnItChildUserForParent: self.earnItChildUserForParent, earnItChildUsers: self.earnItChildUsers)
            let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
            
            let slideMenuController  = SlideMenuViewController(mainViewController: parentDashBoardCheckin, leftMenuViewController: optionViewControllerPD)
            
            slideMenuController.automaticallyAdjustsScrollViewInsets = true
            slideMenuController.delegate = parentDashBoardCheckin
            self.present(slideMenuController, animated:false, completion:nil)
        }
        self.dayTasks = getDayTaskListForParent(earnItTasks: taskForDaysTask)
        self.overdueTasks = getOverDueTaskListForParent(earnItTasks: taskForOverdueTasks)
        self.childTableForTodayTask.reloadData()
        
    }
    
    
    // MARK: - NonSpecific User Functions
    
    /**
     Creates request for keyboardWillShow
     
     - Parameters:
     
     - nil
     */
    
    private func requestObserver(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParentDashBoard.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParentDashBoard.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardDidHide  , object: nil)
        
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
                    
                    let commentYValue = self.messageView.messageText.frame.size.height + self.taskApprovalView.comments.frame.origin.y
                    
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
                    
                    let commentYValue = self.messageView.messageText.frame.size.height + self.taskApprovalView.comments.frame.origin.y
                    
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
//                let alert = showAlertWithOption(title: "", message: "Login failed")
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: self.dismissScreenToLogin))
//                self.present(alert, animated: true, completion: nil)
//                
            }
            
            DispatchQueue.main.async {
                
                print("done calling background fetch....")
                
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
                
                self.earnItChildUsers = earnItChildUsers
                
                
            }) {  (error) -> () in
                
                print("error")
                
            }
            DispatchQueue.main.async {
                
                print("done background processing for checking screen")
                
                if self.earnItChildUsers.count > 0 {
                    
                    
                    for earnItChildUser in self.earnItChildUsers {
                        
                        if earnItChildUser.childUserId == self.earnItChildUserForParent.childUserId{
                            
                            self.earnItChildUserForParent.earnItTasks = earnItChildUser.earnItTasks
                            
                            self.reloadChildUserTable()
                            self.getGoalListForCurrentUser()
                            self.addTapGestureForTaskRow()
                            
                        }
                        
                    }
                    
                }
       
            }
        }
        
    }
    
    
    func messageContainerDidTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func showMessageView(_ sender: Any) {
        
        let messageContainerView = UIView()
        messageContainerView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        messageContainerView.backgroundColor = UIColor.clear
        messageView.messageText.text = ""
        messageContainerView.addSubview(messageView)
        self.view.addSubview(messageContainerView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.messageContainerDidTap(_:)))
        tap.delegate = self
        messageContainerView.addGestureRecognizer(tap)
        
        messageView.dissmissMe = {
            
            self.messageView.removeFromSuperview()
            messageContainerView.removeFromSuperview()
            //self.enableBackgroundView()
            
        }
        
        messageView.callControllerForSendMessage = {
            
            self.showLoadingView()
            self.messageView.activityIndicator.startAnimating()
            if self.messageView.messageText.text.characters.count == 0 || self.messageView.messageText.text.isEmptyField == true{
                
                self.view.endEditing(true)
                self.view.makeToast("Please enter a message")
//                let alert = showAlert(title: "", message: "Please enter a message")
//                self.present(alert, animated: true, completion: nil)
                
            }else {
                
                
                callUpdateApiForChild(firstName: self.earnItChildUserForParent.firstName,childEmail: self.earnItChildUserForParent.email,childPassword: self.earnItChildUserForParent.password,childAvatar: self.earnItChildUserForParent.childUserImageUrl!,createDate: self.earnItChildUserForParent.createDate,childUserId: self.earnItChildUserForParent.childUserId, childuserAccountId: self.earnItChildUserForParent.childAccountId,phoneNumber: self.earnItChildUserForParent.phoneNumber,fcmKey : self.earnItChildUserForParent.fcmToken, message: self.messageView.messageText.text, success: {
                    
                    (childUdateInfo) ->() in
                    
                    
                    
                    createEarnItAppChildUser( success: {
                        
                        (earnItChildUsers) -> () in
                        
                        EarnItAccount.currentUser.earnItChildUsers = earnItChildUsers
                        self.hideLoadingView()
                        self.messageView.activityIndicator.stopAnimating()
                        self.messageView.removeFromSuperview()
                        messageContainerView.removeFromSuperview()
                        self.view.makeToast("Message sent")
                        
                    }) {  (error) -> () in
                        
                        print("error")
                        
                    }
                    
                }) { (error) -> () in
                    self.hideLoadingView()
                    self.view.makeToast("Message sending failed")
//                    let alert = showAlert(title: "Error", message: "Update Child Failed")
//                    self.present(alert, animated: true, completion: nil)
//                    print(" Set status completed failed")
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
    @IBAction func viewDidTap(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func userImageViewGotTapped(_ sender: UITapGestureRecognizer) {
    
        
        let optionView  = (Bundle.main.loadNibNamed("OptionView", owner: self, options: nil)?[0] as? OptionView)!
        optionView.center = self.view.center
        optionView.userImageView.image = self.userImageView.image
        optionView.frame.origin.y = self.userImageView.frame.origin.y
        optionView.frame.origin.x = self.view.frame.origin.x + 39
        
        
        
//        optionView.addTaskButton.setImage(EarnItImage.setEarnItAddIcon(), for: .normal)
//        optionView.showAllTaskButton.setImage(EarnItImage.setEarnItPageIcon(), for: .normal)
//        optionView.approveTaskButton.setImage(EarnItImage.setEarnItAppShowTaskIcon(), for: .normal)
//        optionView.showBalanceButton.setImage(EarnItImage.setEarnItAppBalanceIcon(), for: .normal)
//        optionView.showGoalButton.setImage(EarnItImage.setEarnItGoalIcon(), for: .normal)
//        optionView.messageButton.setImage(EarnItImage.setEarnItCommentIcon(), for: .normal)
        
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
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let parentDashBoardCheckin = storyBoard.instantiateViewController(withIdentifier: "parentDashBoard") as! ParentDashBoard
            parentDashBoardCheckin.prepareData(earnItChildUserForParent: self.earnItChildUserForParent, earnItChildUsers: self.earnItChildUsers)
            let optionViewControllerPD = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
            
            let slideMenuController  = SlideMenuViewController(mainViewController: parentDashBoardCheckin, leftMenuViewController: optionViewControllerPD)
            
            slideMenuController.automaticallyAdjustsScrollViewInsets = true
            slideMenuController.delegate = parentDashBoardCheckin
            self.present(slideMenuController, animated:false, completion:nil)
            
            
        }
        
        optionView.doActionForFirstOption = {
            
            
            self.removeActionView()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let taskViewController = storyBoard.instantiateViewController(withIdentifier: "TaskView") as! TaskViewController
            taskViewController.earnItChildUserId = self.earnItChildUserForParent.childUserId
            taskViewController.earnItChildUsers = self.earnItChildUsers
            self.present(taskViewController, animated:false, completion:nil)
        }
        
        optionView.doActionForFifthOption = {
            
            self.removeActionView()
            print("self.selectedChildUser");
            
            print(self.earnItChildUserForParent);
            getGoalsForChild(childId : self.earnItChildUserForParent.childUserId,success: {
                (earnItGoalList) ->() in
                
                //print("GOAL", earnItGoalList.count);
                // print(earnItGoalList);
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let goalViewController = storyBoard.instantiateViewController(withIdentifier: "GoalViewController") as! GoalViewController
                
                if(self.earnItChildUserForParent.earnItGoal.name == "" || self.earnItChildUserForParent.earnItGoal.name == nil){
                    
                    goalViewController.IS_ADD=true
                }else {
                    
                    goalViewController.IS_ADD=false
                }
                
                goalViewController.earnItChildUser = self.earnItChildUserForParent
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
            self.goToBalanceScreen()
            
        }
        
        optionView.doActionForThirdOption = {
            
            self.removeActionView()
            
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
                    
                    
                    callUpdateApiForChild(firstName: self.earnItChildUserForParent.firstName,childEmail: self.earnItChildUserForParent.email,childPassword: self.earnItChildUserForParent.password,childAvatar: self.earnItChildUserForParent.childUserImageUrl!,createDate: self.earnItChildUserForParent.createDate,childUserId: self.earnItChildUserForParent.childUserId, childuserAccountId: self.earnItChildUserForParent.childAccountId,phoneNumber: self.earnItChildUserForParent.phoneNumber,fcmKey : self.earnItChildUserForParent.fcmToken, message: self.messageView.messageText.text, success: {
                        
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

    func goToBalanceScreen(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let balanceScreen = storyBoard.instantiateViewController(withIdentifier: "BalanceScreen") as! BalanceScreeen
        balanceScreen.earnItChildUsers = self.earnItChildUsers
        balanceScreen.earnItChildUser = self.earnItChildUserForParent
        
        if self.earnItChildUserForParent.earnItGoal.cash! + self.earnItChildUserForParent.earnItGoal.tally! + self.earnItChildUserForParent.earnItGoal.ammount! == 0 {
            
            self.view.makeToast("No balance to display!!")
            
        }else {
            
            self.present(balanceScreen, animated:true, completion:nil)
        }
    }

    
    
}



