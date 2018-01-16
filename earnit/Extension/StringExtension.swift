//
//  StringExtension.swift
//  earnit
//
//  Created by Lovelini Rawat on 7/14/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation


extension String {
    
    //Validate Email
    var isNumber: Bool {
        
        let letters = NSCharacterSet.letters
        
        //if self.rangeOfCharacterFromSet(digit) == nil {
        if  self.rangeOfCharacter(from: letters) == nil{
            
            return true
            
        }else {
            
            return false
        }
    }
    
    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    var isEmptyField: Bool {
       // return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == ""
     let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if trimmedString == ""{
            
            return true
            
        }else {
            
            return false
        }
    }
}
