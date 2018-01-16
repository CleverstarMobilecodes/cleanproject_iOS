//
//  AppDelegate.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/4/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import UIKit
import CoreData
import SlideMenuControllerSwift
import AWSCore
import AWSS3
import Firebase
import FirebaseMessaging
import UserNotifications
import KeychainSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , SlideMenuControllerDelegate{
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent
        self.configureAWSForImageUpload()
        
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        let keychain = KeychainSwift()
        
        
        let email = keychain.get("email")
        let password = keychain.get("password")
        
        
       
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        print("is active user.. \(String(describing: keychain.getBool("isActiveUser")?.description))")
        if let isActiveUser = keychain.getBool("isActiveUser"){
            if isActiveUser {
                print("active user")
                checkUserAuthentication(email: email, password: password, success: {
                    
                    (responseJSON) ->() in
                    
                    print("Reponse json after login - \(responseJSON)")
                    
                    let keychain = KeychainSwift()
                    keychain.set(responseJSON["email"].stringValue, forKey: "email")
                    keychain.set(responseJSON["password"].stringValue, forKey: "password")
                    
                    if (responseJSON["userType"].stringValue == "CHILD"){
                        
                        print("App delegate  going to child Page")
                        EarnItChildUser.currentUser.setAttribute(json: responseJSON)
                        
                        if EarnItChildUser.currentUser.childMessage == nil || EarnItChildUser.currentUser.childMessage == "" {
                            
                            let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "childDashBoard") as! ChildDashBoard
                            self.window?.rootViewController = childDashBoard
                            
                            
                        }else {
                            
                            let childDashBoard = storyBoard.instantiateViewController(withIdentifier: "MessageDisplayScreen") as! MessageDisplayScreen
                            self.window?.rootViewController = childDashBoard
                            
                            
                        }
                        
                    }else {
                        let isProfileUpdaet =  keychain.getBool("isProfileUpdated")
                        if  isProfileUpdaet == true {
                            
                            print("App delegate  going to Landing Page")
                            EarnItAccount.currentUser.setAttribute(json: responseJSON)
                            
                            let parentLandingPage  = storyBoard.instantiateViewController(withIdentifier: "ParentLandingPage") as! ParentLandingPage
                            
                            let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                            
                            let slideMenuController  = SlideMenuViewController(mainViewController: parentLandingPage, leftMenuViewController: optionViewController)
                            
                            slideMenuController.automaticallyAdjustsScrollViewInsets = true
                            slideMenuController.delegate = parentLandingPage
                            
                            self.window?.rootViewController = slideMenuController
                        }
                        else {
                            print("App delegate  going to First time profile screen")
                            EarnItAccount.currentUser.setAttribute(json: responseJSON)
                            
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let profilePage  = storyBoard.instantiateViewController(withIdentifier: "FirstTimeLoginProfileUpdateScreen") as! FirstTimeLoginProfileScreen
                            //   profilePage.shouldGoBackToLandingPage = true
                            
                         //   let optionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionView") as! OptionViewController
                            
                       //     let slideMenuController  = SlideMenuViewController(mainViewController: profilePage, leftMenuViewController: optionViewController)
                            
                        //    slideMenuController.automaticallyAdjustsScrollViewInsets = true
                            //slideMenuController.delegate = profilePage
                            self.window?.rootViewController = profilePage

                        }
                     
                        
                    }
                    
                }) { (error) -> () in
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginPage = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
                    self.window?.rootViewController = loginPage
                    
                }
                
            }
            else {
                print("App delegate  going to Login Page")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginPage = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
                self.window?.rootViewController = loginPage
            }
            
        }else {
            
             print("App delegate  going to Login Page")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginPage = storyBoard.instantiateViewController(withIdentifier: "LoginController") as! LoginPageController
            self.window?.rootViewController = loginPage
        }
        
        
        
        return true
    }
    
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
        print("didRefreshRegistrationToken called")
        print("Firebase registration token: \(fcmToken)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("didRegisterForRemoteNotificationsWithDeviceToken called")
        if let refreshedToken = InstanceID.instanceID().token() {
            print("FCM token: \(refreshedToken)")
            Messaging.messaging().apnsToken = deviceToken
            let keychain = KeychainSwift()
            keychain.set(refreshedToken, forKey: "token")
            
        }
    }
    
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        print("Inside didReceive remoteMessage ")
        print("\(remoteMessage)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Inside didReceiveRemoteNotification" )
        print("userInfo \(userInfo)")
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "earnit")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
  
    func configureAWSForImageUpload(){
        //Creating  default service configuration for AWS
        let credentialsProvider = AWSStaticCredentialsProvider.init(accessKey: AWS_ACCESS_ID, secretKey: AWS_SECRET_KEY)
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.usWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
        
    }
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        let userInfo = notification.request.content.userInfo
        // Print message ID.
      //  print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
        var body = ""
        var title = ""
        var msgUrl = ""
        
        guard let aps = userInfo["aps"] as? [String : AnyObject] else {
            
            print("Error while parsing aps")
            return
        }
        
        if let  alert =  aps["alert"] as? String {
            
            body = alert
            
        }else if let alert =  aps["alert"] as? [String: String] {
            
            body = alert["body"]!
            title = alert["title"]!
        }
        if let category =  aps["category"] as? String {
            
            msgUrl = category
        }
        
        
        print("alert body \(body)")
        print("alert title \(title)")
        
        let center =  UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.delegate = self
        
        center.requestAuthorization(options: [ .alert, .badge, .sound]) { (granted, error) in
            
            if granted {
                
                print("notificaiton granted")
            } else {
                
                print("notificaiton not granted")
            }
            
        }
        
        let date = Date()
        let calendar =  Calendar.current
        var components  = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: date as Date)
        
        let trigger =  UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content =  UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        let request = UNNotificationRequest(identifier: "alertNotification", content: content, trigger: trigger)
        
        center.removeAllPendingNotificationRequests()
        
        center.add(request, withCompletionHandler: {(error) in
            
            if error != nil{
                
                print("Error occured for notification")
                
            }else{
                
                print("got notification")
            }
        })
        
        
    }
}

extension AppDelegate : MessagingDelegate {
    // Receive data message on iOS 10 devices.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}

