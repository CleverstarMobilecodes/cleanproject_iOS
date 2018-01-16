//
//  CalendarControllerViewController.swift
//  earnit
//
//  Created by Prakash Chettri on 18/07/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    private weak var calendar: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        self.view.backgroundColor = UIColor.EarnItAppBackgroundColor()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func loadView() {
        
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.groupTableViewBackground
        self.view = view
        
        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 400 : 300

        let calendar = FSCalendar(frame: CGRect(x: 0, y: 30, width: self.view.bounds.width, height: height))
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.backgroundColor = UIColor.EarnItAppBackgroundColor()
        self.view.addSubview(calendar)
        
        self.calendar = calendar
        
        //Style the calendar view
        self.calendar.appearance.headerTitleColor = UIColor.white
        self.calendar.appearance.titleDefaultColor = UIColor.white
        self.calendar.appearance.weekdayTextColor = UIColor.white
        
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        print("date didSelect")
        print(date)
        dismiss(animated: true, completion: nil)


        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { (make) in
            make.height.equalTo(bounds.height)
            // Do other updates
        }
        self.view.layoutIfNeeded()
    }
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance,  titleDefaultColorFor date: Date) -> UIColor? {
//        
//        return UIColor.white
//    }


}
