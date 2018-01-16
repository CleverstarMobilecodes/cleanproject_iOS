//
//  ChildDashBoard.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/11/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift


class ChildDashBoard : UIViewController ,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var childUserTable: UITableView!
    @IBOutlet var userImageVieqw: UIImageView!
    var earnItChildUsers = [EarnItChildUser]()
    var completedTask = EarnItTask()
    var dayTasks = [DayTask]()
    var detailView = DetailView()
    var overDueTasks = [EarnItTask]()
    var pendingApprovalTasks = [EarnItTask]()
    var timerTest : Timer?
    
    //layout contraint for the detailView box
    var constX:NSLayoutConstraint?
    
    //layout contraint for the detailView box
    var constY:NSLayoutConstraint?
    
    var actionView = UIView()

    struct TappedSectionDetails {
        var sectionNo = 0
        var isCollapsed = false
        
    }
    
    var SectionDetailsArray = [TappedSectionDetails]()


    //override
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        self.actionView.frame = CGRect(0 , 0, self.view.frame.width, self.view.frame.height)
        let tapGestureForActionView = UITapGestureRecognizer(target: self, action: #selector(self.actionViewDidTapped(_:)))
        self.actionView.addGestureRecognizer(tapGestureForActionView)

        self.childUserTable.register(UINib(nibName: "ChildTaskDetailCell", bundle: nil), forCellReuseIdentifier: "ChildTaskDetailCell")
        //let userAvatarUrlString = EarnItChildUser.currentUser.childAvatar
        
        //_ = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.fetchUserDetailFromBackground), userInfo: nil, repeats: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChildDashBoard.userImageDidTapped(gesture:)))
        
        tapGesture.delegate = self
        self.userImageVieqw.addGestureRecognizer(tapGesture)
        self.userImageVieqw.isUserInteractionEnabled = true
        self.childUserTable.tableFooterView = UIView()
        self.setChildInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.startTimerForFetchingUserDetail()
        self.setChildInfo()
    }

    
    func setChildInfo(){
        
        var tasks =  getTodayandFutureTask(earnItTasks: EarnItChildUser.currentUser.earnItTasks)
        self.dayTasks = getDayTaskListForChildUser(earnItTasks: tasks)
        self.overDueTasks = getOverDueTaskListForChildDashBoard(earnItTasks: EarnItChildUser.currentUser.earnItTasks)
        self.pendingApprovalTasks = getPendingApprovalTasks(earnItTasks: EarnItChildUser.currentUser.earnItTasks)

        self.userImageVieqw.loadImageUsingCache(withUrl: EarnItChildUser.currentUser.childUserImageUrl)
        self.childUserTable.reloadData()
        self.getGoalForCurrentUser()

    }
    
    @IBAction func childTableViewGotTapped(_ sender: UITapGestureRecognizer) {
       
        if sender.state == UIGestureRecognizerState.ended {
            let tapLocation = sender.location(in: self.childUserTable)
            if let tappedIndexPath = self.childUserTable.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.childUserTable.cellForRow(at: tappedIndexPath) {
                    
                    
                      if self.pendingApprovalTasks.count > 0{
                        if self.overDueTasks.count > 0 {
                            
                            if (tappedIndexPath.section == 0 ){
                                
                                self.view.makeToast("Already been submitted for approval")
                                
                            }
                            else if(tappedIndexPath.section == 1 )  {
                                
                                
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
                                taskSubmitScreen.earnItTask = self.overDueTasks[tappedIndexPath.row]
                                self.present(taskSubmitScreen, animated:true, completion:nil)

                                
                            }
                            else
                            {
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
                                taskSubmitScreen.earnItTask = self.dayTasks[tappedIndexPath.section - 2].earnItTasks[tappedIndexPath.row]
                                self.present(taskSubmitScreen, animated:true, completion:nil)

                            }
                        }
                        else {
                            
                            if (tappedIndexPath.section == 0 ){
                                
                                self.view.makeToast("Already been submitted for approval")
                            }
                            else
                            {
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
                                taskSubmitScreen.earnItTask = self.dayTasks[tappedIndexPath.section - 1].earnItTasks[tappedIndexPath.row]
                                self.present(taskSubmitScreen, animated:true, completion:nil)
                            }
                            
                        }
                    }
                        
                    else if self.overDueTasks.count > 0 {
                        
                        if (tappedIndexPath.section == 0 ){
                            
                            
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                            let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
                            taskSubmitScreen.earnItTask = self.overDueTasks[tappedIndexPath.row]
                            self.present(taskSubmitScreen, animated:true, completion:nil)
                            
                        }
                        else
                        {
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                            let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
                            taskSubmitScreen.earnItTask = self.dayTasks[tappedIndexPath.section - 1].earnItTasks[tappedIndexPath.row]
                            self.present(taskSubmitScreen, animated:true, completion:nil)
                        }

                    }
                        
                    else {
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                        let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
                        taskSubmitScreen.earnItTask = self.dayTasks[tappedIndexPath.section].earnItTasks[tappedIndexPath.row]
                        self.present(taskSubmitScreen, animated:true, completion:nil)

                        
                    }
                    
                    
                    
                    
                    
                    
//                    if self.overDueTasks.count > 0 {
//                        
//                        if tappedIndexPath.section == 0{
//                            
//                           // self.showPopup(task: self.overDueTasks[tappedIndexPath.row])
//                            
//                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//                            let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
//                            taskSubmitScreen.earnItTask = self.overDueTasks[tappedIndexPath.row]
//                            self.present(taskSubmitScreen, animated:true, completion:nil)
//                            
//                        }else {
//                            
//                            //self.showPopup(task: self.dayTasks[tappedIndexPath.section - 1].earnItTasks[tappedIndexPath.row])
//                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//                            let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
//                            taskSubmitScreen.earnItTask = self.dayTasks[tappedIndexPath.section - 1].earnItTasks[tappedIndexPath.row]
//                            self.present(taskSubmitScreen, animated:true, completion:nil)
//                        }
//                        
//                    }
//                    else {
//                        
//                       // self.showPopup(task: self.dayTasks[tappedIndexPath.section].earnItTasks[tappedIndexPath.row])
//                        
//                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//                        let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
//                        taskSubmitScreen.earnItTask = self.dayTasks[tappedIndexPath.section].earnItTasks[tappedIndexPath.row]
//                        self.present(taskSubmitScreen, animated:true, completion:nil)
//                        
//                    }
                    
                }
                
            }
            
        }
        
    }
  

    @IBAction func openOption(_ sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let calendarView = storyBoard.instantiateViewController(withIdentifier: "CalendarView") as! CalendarViewController
        self.present(calendarView, animated: false, completion: nil)

        
    }
       //override
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //override
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        
//        var numberOfSectionToReturn = 1
//        
//        if self.overDueTasks.count > 0 {
//            
//            numberOfSectionToReturn = self.dayTasks.count + 1
//            
//        }else {
//            
//            numberOfSectionToReturn =  self.dayTasks.count
//        }
//        
//        print("number of section \(numberOfSectionToReturn)")
//        return numberOfSectionToReturn
//    }
//
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSectiontoReturn  = 0
        
        
        if self.pendingApprovalTasks.count > 0  {
            
            if self.overDueTasks.count > 0 {
                
                numberOfSectiontoReturn =  self.dayTasks.count + 2
                
            }
            else
            {
                numberOfSectiontoReturn =  self.dayTasks.count + 1
                
            }
        }
            
        else if self.overDueTasks.count > 0 {
            
            numberOfSectiontoReturn =  self.dayTasks.count + 1
        }
            
        else {
            numberOfSectiontoReturn =  self.dayTasks.count
        }
        

        for i in 0...numberOfSectiontoReturn {
            var sectionDetail = TappedSectionDetails()
            sectionDetail.sectionNo = i
            sectionDetail.isCollapsed = false
            
            SectionDetailsArray.append(sectionDetail)
        }

        
        return numberOfSectiontoReturn
    }

    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        var numberOfRows = 1
//        
//        if self.overDueTasks.count > 0 {
//        
//        if section == 0{
//            
//            numberOfRows = self.overDueTasks.count
//            
//        }else {
//            
//            numberOfRows = self.dayTasks[section-1].earnItTasks.count
//         }
//        
//        }else {
//            
//            numberOfRows = self.dayTasks[section].earnItTasks.count
//        }
//        
//        
//        print("number of row = \(numberOfRows)")
//        return numberOfRows
//    
//    
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        var  numberOfRows = 0
        
        if self.pendingApprovalTasks.count > 0   {
            if self.overDueTasks.count > 0 {
                
                if (section == 0){
                    
                    numberOfRows =  self.pendingApprovalTasks.count
                }
                else if (section == 1){
                    
                    numberOfRows = self.overDueTasks.count
                    
                }
                    
                else{
                    numberOfRows = self.dayTasks[section-2].earnItTasks.count
                }
                
            }
            else {
                
                if (section == 0){
                    numberOfRows = self.pendingApprovalTasks.count
                }
                else{
                    numberOfRows = self.dayTasks[section-1].earnItTasks.count
                    
                }
                
            }
            
        }
        else if self.overDueTasks.count > 0 {
            
            if (section == 0){
                numberOfRows = self.overDueTasks.count
            }
                
            else{
                
                numberOfRows = self.dayTasks[section-1].earnItTasks.count
            }
            
        }
        else
        {
            numberOfRows = self.dayTasks[section].earnItTasks.count
            
        }
        
        
        if SectionDetailsArray[section].isCollapsed {
            return 0
            
        }
            
        else {
            
            return numberOfRows
        }

    }
    
    
    func configureTableCell(taskCell:ChildTaskDetailCell, type:String, indexPath:NSIndexPath ) -> ChildTaskDetailCell {
        
        if type == "PendingApproval" {
            
            taskCell.taskName.text = self.pendingApprovalTasks[indexPath.row].taskName
            taskCell.taskDescription.text = self.pendingApprovalTasks[indexPath.row].dateMonthString + " @ " + self.pendingApprovalTasks[indexPath.row].dueTime
            
            taskCell.statusImage.backgroundColor = getColorStatusForTaskForChildDashBoard(earnItTask: self.pendingApprovalTasks[indexPath.row])
            
            //taskCell.checkButton.backgroundColor = UIColor.clear
            //taskCell.layer.borderColor = UIColor.white.cgColor
            //taskCell.layer.borderWidth = 1
            // taskCell.checkButton.setImage(nil, for: .normal)
            
            
            taskCell.askToRemoveTheCompletedTask = {
                
                self.completedTask = self.pendingApprovalTasks[indexPath.row]
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
                
                print("taskName \(self.completedTask.taskName)")
                print("taskdes \(self.completedTask.taskDescription)")
                print("ispicturereq \(self.completedTask.isPictureRequired)")
                taskSubmitScreen.earnItTask = self.completedTask
                //taskSubmitScreen.isPictureRequired = self.completedTask.isPictureRequired
                //taskSubmitScreen.taskNameLabel.text = "hello"
                //taskSubmitScreen.taskDescription.text = self.completedTask.taskDescription
                self.present(taskSubmitScreen, animated:true, completion:nil)
            }
            
            
        }
        else if type == "OverDue" {
            
            taskCell.taskName.text = self.overDueTasks[indexPath.row].taskName
            taskCell.taskDescription.text = self.overDueTasks[indexPath.row].dateMonthString + " @ " + self.overDueTasks[indexPath.row].dueTime
            
            taskCell.statusImage.backgroundColor = getColorStatusForTaskForChildDashBoard(earnItTask: self.overDueTasks[indexPath.row])
            
            //taskCell.checkButton.backgroundColor = UIColor.clear
            //taskCell.layer.borderColor = UIColor.white.cgColor
            //taskCell.layer.borderWidth = 1
            // taskCell.checkButton.setImage(nil, for: .normal)
            
            
            
            taskCell.askToRemoveTheCompletedTask = {
                
                self.completedTask = self.overDueTasks[indexPath.row]
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
                
                print("taskName \(self.completedTask.taskName)")
                print("taskdes \(self.completedTask.taskDescription)")
                print("ispicturereq \(self.completedTask.isPictureRequired)")
                taskSubmitScreen.earnItTask = self.completedTask
                //taskSubmitScreen.isPictureRequired = self.completedTask.isPictureRequired
                //taskSubmitScreen.taskNameLabel.text = "hello"
                //taskSubmitScreen.taskDescription.text = self.completedTask.taskDescription
                self.present(taskSubmitScreen, animated:true, completion:nil)
                
            }
        }
            
        else if type == "DayTask" {
            
            
            taskCell.taskName.text = self.dayTasks[indexPath.section].earnItTasks[indexPath.row].taskName
            taskCell.taskDescription.text = self.dayTasks[indexPath.section].earnItTasks[indexPath.row].dateMonthString + " @ " + self.dayTasks[indexPath.section].earnItTasks[indexPath.row].dueTime
            
            taskCell.statusImage.backgroundColor = getColorStatusForTaskForChildDashBoard(earnItTask: self.dayTasks[indexPath.section].earnItTasks[indexPath.row])
            
            //taskCell.checkButton.setImage(nil, for: .normal)
            
            taskCell.askToRemoveTheCompletedTask = {
                
                self.completedTask = self.dayTasks[indexPath.section].earnItTasks[indexPath.row]
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
                taskSubmitScreen.earnItTask = self.completedTask
                //taskSubmitScreen.isPictureRequired = self.completedTask.isPictureRequired
                //taskSubmitScreen.taskNameLabel.text = self.completedTask.taskName
                //taskSubmitScreen.taskDescription.text = self.completedTask.taskDescription
                
                self.present(taskSubmitScreen, animated:true, completion:nil)
                
                
                
            }
            
        }
        return taskCell
        
    }
    
    
    
    
    
    //override
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//        
//        let taskCell = self.childUserTable.dequeueReusableCell(withIdentifier: "ChildTaskDetailCell", for: indexPath as IndexPath) as! ChildTaskDetailCell
//        //taskCell.taskName = ""
//        
//        
//        if self.overDueTasks.count > 0 {
//        
//        if (indexPath.section == 0){
//            
//
//            
//            taskCell.taskName.text = self.overDueTasks[indexPath.row].taskName
//            taskCell.taskDescription.text = self.overDueTasks[indexPath.row].dateMonthString + " @ " + self.overDueTasks[indexPath.row].dueTime
//            
//            taskCell.statusImage.backgroundColor = getColorStatusForTaskForChildDashBoard(earnItTask: self.overDueTasks[indexPath.row])
//            
//            //taskCell.checkButton.backgroundColor = UIColor.clear
//            //taskCell.layer.borderColor = UIColor.white.cgColor
//            //taskCell.layer.borderWidth = 1
//            // taskCell.checkButton.setImage(nil, for: .normal)
//            
//
//            
//            taskCell.askToRemoveTheCompletedTask = {
//                
//                self.completedTask = self.overDueTasks[indexPath.row]
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
//                
//                print("taskName \(self.completedTask.taskName)")
//                 print("taskdes \(self.completedTask.taskDescription)")
//                 print("ispicturereq \(self.completedTask.isPictureRequired)")
//                taskSubmitScreen.earnItTask = self.completedTask
//                //taskSubmitScreen.isPictureRequired = self.completedTask.isPictureRequired
//                //taskSubmitScreen.taskNameLabel.text = "hello"
//                //taskSubmitScreen.taskDescription.text = self.completedTask.taskDescription
//                self.present(taskSubmitScreen, animated:true, completion:nil)
//
//            }
//            
//        }else {
//        
//        
//
//        
//            
//            taskCell.taskName.text = self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row].taskName
//            taskCell.taskDescription.text = self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row].dateMonthString + " @ " + self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row].dueTime
//        
//        
//            taskCell.statusImage.backgroundColor = getColorStatusForTaskForChildDashBoard(earnItTask: self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row])
//            
//        
//            //taskCell.checkButton.setImage(nil, for: .normal)
//            
//            taskCell.askToRemoveTheCompletedTask = {
//            
//            self.completedTask = self.dayTasks[indexPath.section - 1].earnItTasks[indexPath.row]
//                
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
//                taskSubmitScreen.earnItTask = self.completedTask
//               // taskSubmitScreen.isPictureRequired = self.completedTask.isPictureRequired
//                //taskSubmitScreen.taskNameLabel.text = self.completedTask.taskName
//                //taskSubmitScreen.taskDescription.text = self.completedTask.taskDescription
//                
//                self.present(taskSubmitScreen, animated:true, completion:nil)
//       
//            
//              }
//
//          }
//            
//        }else {
//            
//        
//            taskCell.taskName.text = self.dayTasks[indexPath.section].earnItTasks[indexPath.row].taskName
//            taskCell.taskDescription.text = self.dayTasks[indexPath.section].earnItTasks[indexPath.row].dateMonthString + " @ " + self.dayTasks[indexPath.section].earnItTasks[indexPath.row].dueTime
//            
//            taskCell.statusImage.backgroundColor = getColorStatusForTaskForChildDashBoard(earnItTask: self.dayTasks[indexPath.section].earnItTasks[indexPath.row])
//            
//            //taskCell.checkButton.setImage(nil, for: .normal)
//            
//            taskCell.askToRemoveTheCompletedTask = {
//                
//                self.completedTask = self.dayTasks[indexPath.section].earnItTasks[indexPath.row]
//                
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//                let taskSubmitScreen = storyBoard.instantiateViewController(withIdentifier: "TaskSubmitScreen") as! TaskSubmitScreen
//                taskSubmitScreen.earnItTask = self.completedTask
//                //taskSubmitScreen.isPictureRequired = self.completedTask.isPictureRequired
//                //taskSubmitScreen.taskNameLabel.text = self.completedTask.taskName
//                //taskSubmitScreen.taskDescription.text = self.completedTask.taskDescription
//                
//                self.present(taskSubmitScreen, animated:true, completion:nil)
//                
//
//            }
//            
//        }
//        
//        return taskCell
//    }
//    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        
        
        var taskCell = self.childUserTable.dequeueReusableCell(withIdentifier: "ChildTaskDetailCell", for: indexPath as IndexPath) as! ChildTaskDetailCell
        
        
        if self.pendingApprovalTasks.count > 0   {
            if self.overDueTasks.count > 0 {
                
                if (indexPath.section == 0){
                    
                    taskCell = self.configureTableCell(taskCell: taskCell, type: "PendingApproval", indexPath: indexPath as NSIndexPath)
                    
                }
                    
                else if (indexPath.section == 1){
                    
                    taskCell = self.configureTableCell(taskCell: taskCell, type: "OverDue", indexPath: indexPath as NSIndexPath)
                    
                }
                    
                else{
                    
                    var tempIndexPath = indexPath
                    tempIndexPath.section = tempIndexPath.section - 2
                    taskCell = self.configureTableCell(taskCell: taskCell, type: "DayTask", indexPath: tempIndexPath as NSIndexPath)
                    
                }
                
            }
            else {
                
                if (indexPath.section == 0){
                    taskCell = self.configureTableCell(taskCell: taskCell, type: "PendingApproval", indexPath: indexPath as NSIndexPath)
                    
                }
                else{
                    
                    var tempIndexPath = indexPath
                    tempIndexPath.section = tempIndexPath.section - 1
                    
                    taskCell = self.configureTableCell(taskCell: taskCell, type: "DayTask", indexPath: tempIndexPath as NSIndexPath)
                }
                
            }
            
        }
        else if self.overDueTasks.count > 0 {
            
            if (indexPath.section == 0){
                taskCell = self.configureTableCell(taskCell: taskCell, type: "OverDue", indexPath: indexPath as NSIndexPath)
                
            }
                
            else{
                var tempIndexPath = indexPath
                tempIndexPath.section = tempIndexPath.section - 1
                taskCell = self.configureTableCell(taskCell: taskCell, type: "DayTask", indexPath: tempIndexPath as NSIndexPath)
            }
            
        }
        else
        {
            taskCell = self.configureTableCell(taskCell: taskCell, type: "DayTask", indexPath: indexPath as NSIndexPath)
            
        }
        
        return taskCell
    }
    
    

    //ovrride
    func callControllerForDoneTask(alert: UIAlertAction) {
        
        self.completedTask.status = TaskStatus.completed
        //let goalId = EarnItChildUser.currentUser.earnItGoal.id
        self.showLoadingView()
        print("completed task status \(self.completedTask.status)")
        callApiForUpdateTask(earnItTaskChildId: EarnItChildUser.currentUser.childUserId,earnItTask: self.completedTask, success: {
            
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
                    self.setChildInfo()
                    self.hideLoadingView()
                    
                }else {
                    
                    EarnItAccount.currentUser.setAttribute(json: responseJSON)
                    keychain.set(String(EarnItAccount.currentUser.accountId), forKey: "userId")
                    self.hideLoadingView()
                }
                
            }) { (error) -> () in
                
                
                
            }
           
           
        }) { (error) -> () in
            
            self.view.makeToast("Something went wrong")
//            let alert = showAlert(title: "Error", message: "Failed")
//            self.present(alert, animated: true, completion: nil)
//            print(" Set status completed failed")
            self.hideLoadingView()
        }
        
    }

    

    
    //ovrride
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let view  = Bundle.main.loadNibNamed("DayHeader", owner: nil, options: nil)?.first as! DayHeader
//    
//        if self.overDueTasks.count > 0{
//            
//        if (section == 0){
//            
//            view.dayDetail.text = "Overdue Tasks"
//            
//        }else if isCurrentDate(earnItTaskDate: self.dayTasks[section - 1].date) {
//            
//            view.dayDetail.text =  "Today's Tasks"
//            
//        }else{
//            
//           view.dayDetail.text =  self.dayTasks[section - 1].dayName + ", " + self.dayTasks[section - 1].date
//         }
//        
//        }else {
//            
//         if isCurrentDate(earnItTaskDate: self.dayTasks[section].date) {
//                
//                view.dayDetail.text =  "Today's Tasks"
//                
//        }else{
//                
//                view.dayDetail.text =  self.dayTasks[section].dayName + ", " + self.dayTasks[section].date
//            }
//
//        }
//    
//        return view
//    }
    

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view  = Bundle.main.loadNibNamed("DayHeader", owner: nil, options: nil)?.first as! DayHeader
        view.sectionNo = section

        if self.pendingApprovalTasks.count > 0   {
            if self.overDueTasks.count > 0 {
                
                if (section == 0){
                    
                    view.dayDetail.text = "Pending Approval"
                }
                else if (section == 1){
                    
                    view.dayDetail.text = "Past Due"
                }
                else if isCurrentDate(earnItTaskDate: self.dayTasks[section - 2].date) {
                    
                    view.dayDetail.text =  "Today" + " " + self.dayTasks[section - 2].date
                }
                else{
                    
                    view.dayDetail.text =  self.dayTasks[section - 2].dayName + " " + self.dayTasks[section-2].date
                }
                
            }
            else {
                
                if (section == 0){
                    
                    view.dayDetail.text = "Pending Approval"
                }
                    
                else if isCurrentDate(earnItTaskDate: self.dayTasks[section - 1].date) {
                    
                    view.dayDetail.text =  "Today" + " " + self.dayTasks[section - 1].date
                }
                else{
                    
                    view.dayDetail.text =  self.dayTasks[section-1].dayName + " " + self.dayTasks[section-1].date
                }
                
            }
            
        }
        else if self.overDueTasks.count > 0 {
            
            if (section == 0){
                
                view.dayDetail.text = "Past Due"
            }
            else if isCurrentDate(earnItTaskDate: self.dayTasks[section - 1].date) {
                
                view.dayDetail.text = "Today" + " " + self.dayTasks[section - 1].date            }
            else{
                
                view.dayDetail.text =  self.dayTasks[section-1].dayName + " " + self.dayTasks[section-1].date
            }
            
        }
        else {
            
            if isCurrentDate(earnItTaskDate: self.dayTasks[section].date) {
                
                view.dayDetail.text =  "Today" + " " + self.dayTasks[section ].date
                
            }
            else{
                
                view.dayDetail.text =  self.dayTasks[section].dayName + " " + self.dayTasks[section].date
            }
            
        }
        
        
        
        //          if self.overdueTasks.count > 0{
        //
        //            if (section == 0){
        //
        //                view.dayDetail.text = "Overdue Tasks"
        //
        //            }
        //            else if isCurrentDate(earnItTaskDate: self.dayTasks[section - 1].date) {
        //
        //                view.dayDetail.text =  "Today's Tasks"
        //
        //            }
        //            else{
        //
        //                view.dayDetail.text =  self.dayTasks[section - 1].dayName + ", " + self.dayTasks[section - 1].date
        //               }
        //          }
        //          else {
        //
        //            if isCurrentDate(earnItTaskDate: self.dayTasks[section].date) {
        //
        //                view.dayDetail.text =  "Today's Tasks"
        //
        //            }
        //            else{
        //                
        //                view.dayDetail.text =  self.dayTasks[section].dayName + ", " + self.dayTasks[section].date
        //            }
        //            
        //          }
        
        
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
        self.childUserTable.reloadSections((NSIndexSet(index: Header.sectionNo) as IndexSet), with: .automatic)
    }

    
    
    
    
    
    func showPopup(task: EarnItTask){
        
            self.childUserTable.isUserInteractionEnabled = false
            detailView = (Bundle.main.loadNibNamed("DetailView", owner: self, options: nil)?[0] as? DetailView)!
            
        
            detailView.TaskName.text = task.taskName
            detailView.Allowance.text = "$" + String(task.allowance)
            detailView.expiryDate.text = task.dateMonthString + " @ " + task.dueTime
            detailView.createdDate.text = task.createdDateMonthString + " @ " + task.createdDateTime
        
        
            detailView.close.addTarget(self, action: #selector(self.closeDetailView), for: UIControlEvents.touchUpInside)
       
            detailView.center = self.view.center
        
            self.view.addSubview(detailView)
        
            var dView:[String:UIView] = [:]
            dView["DetailView"] = detailView
            
            let h_Pin = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(36)-[DetailView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0) , metrics: nil, views: dView)
            self.view.addConstraints(h_Pin)
            
            let v_Pin = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(36)-[DetailView]-(36)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dView)
            self.view.addConstraints(v_Pin)
            
            constY = NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            self.view.addConstraint(constY!)
            
            
            constX = NSLayoutConstraint(item: detailView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            self.view.addConstraint(constX!)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.50, options: UIViewAnimationOptions.layoutSubviews, animations: { () -> Void in
                self.detailView.alpha = 1
                self.view.layoutIfNeeded()
            }) { (value:Bool) -> Void in
                
            }
            
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

    func closeDetailView(sender: UIButton){
        
         self.childUserTable.isUserInteractionEnabled = true
         hideStatusInputView()
        
    }
        
    // MARK: - function to hidePopupView
    /**
     */
    
    
    func hideStatusInputView(){
    
        self.detailView.removeFromSuperview()
        
    }
    
    
    
    func getGoalForCurrentUser(){
        
        getGoalsForChild(childId : EarnItChildUser.currentUser.childUserId,success: {
            
            (earnItGoalList) ->() in
            
            for earnItGoal in  earnItGoalList {
                
                EarnItChildUser.currentUser.earnItGoal = earnItGoal
    
                
            }
             
            
        })
            
        { (error) -> () in
            
            self.view.makeToast("Get goal list failed")
//            let alert = showAlertWithOption(title: "Add task failed ", message: "")
//            
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        
    }
    
    func fetchUserDetailFromBackground(){
        
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
                
                print("Response : \(responseJSON)")
                
                if (responseJSON["userType"].stringValue == "CHILD"){
                    
                    EarnItChildUser.currentUser.setAttribute(json: responseJSON)
                    //success(true)
                    
                    
                }else {
                    
                    EarnItAccount.currentUser.setAttribute(json: responseJSON)
                    keychain.set(String(EarnItAccount.currentUser.accountId), forKey: "userId")
                   // success(true)
                }
                
            }) { (error) -> () in
                
           
                self.dismiss(animated: true, completion: nil)
            }

            DispatchQueue.main.async {
                
                print("done calling background fetch....")
                if EarnItChildUser.currentUser.firstName != nil {
                    
                    var tasks =  getTodayandFutureTask(earnItTasks: EarnItChildUser.currentUser.earnItTasks)
                    self.dayTasks = getDayTaskListForChildUser(earnItTasks: tasks)
                    self.overDueTasks = getOverDueTaskListForChild(earnItTasks: EarnItChildUser.currentUser.earnItTasks)
                    self.pendingApprovalTasks = getPendingApprovalTasks(earnItTasks: EarnItChildUser.currentUser.earnItTasks)

                    self.childUserTable.reloadData()
                    self.getGoalForCurrentUser()

                }else {
                    
                    print("response is nil")
                }
             
            }
        }
    }
    
    
    func userImageDidTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        print("User Image got tapped")
        //_ = sender.view as! UIImageView

        let optionView  = (Bundle.main.loadNibNamed("ChildOptionView", owner: self, options: nil)?[0] as? ChildOptionView)!
        optionView.center = self.view.center
        optionView.userImageView.image = self.userImageVieqw.image
        optionView.frame.origin.y = self.userImageVieqw.frame.origin.y
         optionView.frame.origin.x = self.view.frame.origin.x + 160
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 480:
                
                
                optionView.frame.origin.x = self.view.frame.origin.x + 160
                
                
                
            case 960:
                
                
               optionView.frame.origin.x = self.view.frame.origin.x + 160
                
                
                
            case 1136:
                
                
               optionView.frame.origin.x = self.view.frame.origin.x + 105
                
            case 1334:
                
                
               optionView.frame.origin.x = self.view.frame.origin.x + 160
                
                
            case 2208:
                
                
               optionView.frame.origin.x = self.view.frame.origin.x + 200
                
            default:
                
                print("unknown")
            }
            
        }
        else if  UIDevice().userInterfaceIdiom == .pad {
            
            optionView.frame.origin.x = self.view.frame.origin.x + 200
        }
        
        optionView.firstOption.setImage(EarnItImage.setEarnItPageIcon(), for: .normal)
        optionView.secondOption.setImage(EarnItImage.setEarnItAppBalanceIcon(), for: .normal)
        optionView.thirdOption.setImage(EarnItImage.setEarnItLogoutIcon(), for: .normal)
        
        //optionView.sixthOption.setImage(EarnItImage.setEarnItCommentIcon(), for: .normal)
        
        optionView.firstOption.setTitle("View Tasks", for: .normal)
        optionView.secondOption.setTitle("Balances", for: .normal)
        optionView.thirdOption.setTitle("Logout", for: .normal)
      
        self.actionView.addSubview(optionView)
        self.actionView.backgroundColor = UIColor.clear
        self.view.addSubview(self.actionView)
        
        
        optionView.doActionForFirstOption = {
            
            self.removeActionView()
            
            
        }
        
        optionView.doActionForSecondOption = {
            
            
            self.removeActionView()
            self.goToBalanceScreen()
       
        }
        
        optionView.doActionForThirdOption = {
            
            self.removeActionView()
            let keychain = KeychainSwift()
            keychain.delete("isActiveUser")
            keychain.delete("email")
            keychain.delete("password")
            keychain.delete("isProfileUpdated")
            UIApplication.shared.unregisterForRemoteNotifications()
            
            //keychain.delete("token")
            self.stopTimerForFetchingUserDetail()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
            self.present(loginController, animated: false, completion: nil)
            
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

    

    func startTimerForFetchingUserDetail () {
        
        print("startTimerForFetchingUserDetail")
        if timerTest == nil {
            timerTest =  Timer.scheduledTimer(
                timeInterval: 300,
                target      : self,
                selector    : #selector(self.fetchUserDetailFromBackground),
                userInfo    : nil,
                repeats     : true)
        }
    }
    
    func stopTimerForFetchingUserDetail() {
        print("stopTimerForFetchingUserDetail")
        if timerTest != nil {
            timerTest?.invalidate()
            timerTest = nil
        }
    }
    
    
    func goToBalanceScreen(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let balanceScreen = storyBoard.instantiateViewController(withIdentifier: "BalanceScreen") as! BalanceScreeen
        let earnItChildUsers = [EarnItChildUser]()
        balanceScreen.earnItChildUsers =  earnItChildUsers
        balanceScreen.earnItChildUser = EarnItChildUser.currentUser
        balanceScreen.isActiveUserChild = true
        
        if EarnItChildUser.currentUser.earnItGoal.cash! + EarnItChildUser.currentUser.earnItGoal.tally!  + EarnItChildUser.currentUser.earnItGoal.ammount! == 0 {
            
            self.view.makeToast("No balance to display!!")
            
        }else {
            
            self.present(balanceScreen, animated:true, completion:nil)
        }
        
    }
    
    
    
}


