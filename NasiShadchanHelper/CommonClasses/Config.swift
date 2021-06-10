//
//  Config.swift
//  NasiShadchanHelper
//
//  Created by user on 4/26/20.
//  Copyright © 2020 user. All rights reserved.
//

import Foundation



func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

func calculateAgeFrom(dob: Date) -> Double {
    
    let dateOfBirth = dob
    
  
    
    // get today as a date object and compare
    let today = Date()
    
    let calendar = Calendar.current
    
    let components = calendar.dateComponents([.year,.month, .day], from: dateOfBirth, to: today)
    
    let ageYears = components.year
   
    
    let decimal =  Double(components.month!) / Double(12)
    
    
    let compositeNumb = Double(ageYears!) + decimal
    
    let  roundedNumb =    Double(compositeNumb).rounded(toPlaces: 1)
    return roundedNumb
    
}

