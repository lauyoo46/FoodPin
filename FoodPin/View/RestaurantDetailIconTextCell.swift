//
//  RestaurantDetailIconTextCell.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 10/12/2020.
//

import UIKit

class RestaurantDetailIconTextCell: UITableViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var shortTextLabel: UILabel! {
    didSet {
        shortTextLabel.numberOfLines = 0
        }
    }

}
