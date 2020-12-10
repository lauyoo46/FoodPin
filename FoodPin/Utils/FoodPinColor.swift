//
//  FoodPinColor.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 09/12/2020.
//

import UIKit

enum Color {
    
    case shareOrange
    case deleteRed
    case checkGreen
    
    var uiColor: UIColor {
        switch self {
        
        case .shareOrange:
            return UIColor(red: 254.0/255.0, green: 149.0/255.0 , blue: 38.0/255.0, alpha: 1.0)
        case .deleteRed:
            return UIColor(red: 231.0/255.0, green: 76.0/255.0 , blue: 60.0/255.0, alpha: 1.0)
        case .checkGreen:
            return UIColor(red: 35.0/255.0, green: 214.0/255.0 , blue: 0.0/255.0, alpha: 1.0)
        }
    }
}
