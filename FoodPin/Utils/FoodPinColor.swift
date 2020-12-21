//
//  FoodPinColor.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 09/12/2020.
//

import UIKit

enum Color {
    
    case myOrange
    case myRed
    case myGreen
    case myWhite
    
    var uiColor: UIColor {
        switch self {
        
        case .myOrange:
            return UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        case .myRed:
            return UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        case .myGreen:
            return UIColor(red: 35.0/255.0, green: 214.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        case .myWhite:
            return UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/250.0, alpha: 1.0)
        }
    }
}
