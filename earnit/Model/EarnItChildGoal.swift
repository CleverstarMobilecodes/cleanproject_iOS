//
//  EarnItChildGoal.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/21/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import SwiftyJSON

class EarnItChildGoal : NSObject {
    
    //ammount
    var ammount : Int? = 0
    
    //createdDate
    var createdDate : String?
    
    //id
    var id : Int?
    
    //name
    var name : String?
    
    //updateDate
    var updateDate : String?
    
    //tally
    var tally : Int? = 0
    
    //tally percent
    var tallyPercent : Int?
    
    //cash amount
    var cash : Int? = 0
    
    
    override init(){
        
        super.init()
    }
    
    
    init(id: Int, createdDate: String, updateDate: String, name : String, ammount: Int, cash: Int){
        
        super.init()
        self.id = id
        self.createdDate = createdDate
        self.updateDate = updateDate
        self.ammount = ammount
        self.name = name
        self.cash = cash
        
        
    }
    
    init(json: JSON){
        
        super.init()
        self.id = json["id"].intValue
        self.createdDate = json["createdDate"].stringValue
        self.updateDate = json["updateDate"].stringValue
        self.ammount = json["ammount"].intValue
        self.name = json["name"].stringValue
        self.cash = json["cash"].intValue
        
    }
    
    
    func setAttribute(json: JSON){
        

        self.id = json["id"].intValue
        self.createdDate = json["createdDate"].stringValue
        self.updateDate = json["updateDate"].stringValue
        self.ammount = json["amount"].intValue
        self.name = json["name"].stringValue
        self.tally = json["tally"].intValue
        self.tallyPercent = json["tallyPercent"].intValue
        self.cash = json["cash"].intValue

        
    }
    
}
