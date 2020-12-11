//
//  RestaurantDetailTextCell.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 10/12/2020.
//

import UIKit

class RestaurantDetailTextCell: UITableViewCell {

    @IBOutlet var descriptionLabel: UILabel! {
        didSet {
    descriptionLabel.numberOfLines = 0
        }
    }
    
}
