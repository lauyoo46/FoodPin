//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 09/12/2020.
//

import UIKit

class RestaurantDetailViewController: UIViewController {
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    var restaurantImageName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurantImageView.image = UIImage(named: restaurantImageName)
        navigationItem.largeTitleDisplayMode = .never
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
