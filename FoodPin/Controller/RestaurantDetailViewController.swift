//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 09/12/2020.
//

import UIKit

class RestaurantDetailViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: RestaurantDetailHeaderView!
    
    var restaurant = Restaurant()
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        navigationItem.largeTitleDisplayMode = .never
        tableView.dataSource = self
        headerView.nameLabel.text = restaurant.name
        headerView.typeLabel.text = restaurant.type
        headerView.headerImageView.image = UIImage(named: restaurant.image)
        headerView.heartImageView.isHidden = (restaurant.isVisited) ? false : true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        tableView.contentInsetAdjustmentBehavior = .never
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

    // MARK: - Table View Delegate

extension RestaurantDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RestaurantDetailIconTextCell.self),
                for: indexPath) as? RestaurantDetailIconTextCell
            
            guard let safeCell = cell else {
                return UITableViewCell()
            }
            safeCell.iconImageView.image = UIImage(systemName: "phone")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
            safeCell.shortTextLabel.text = restaurant.phone
            safeCell.selectionStyle = .none
            return safeCell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RestaurantDetailIconTextCell.self),
                for: indexPath) as? RestaurantDetailIconTextCell
            
            guard let safeCell = cell else {
                return UITableViewCell()
            }
            safeCell.iconImageView.image = UIImage(systemName: "map")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
            safeCell.shortTextLabel.text = restaurant.location
            safeCell.selectionStyle = .none
            return safeCell
            
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RestaurantDetailTextCell.self),
                for: indexPath) as? RestaurantDetailTextCell
            
            guard let safeCell = cell else {
                return UITableViewCell()
            }
            safeCell.descriptionLabel.text = restaurant.description
            safeCell.selectionStyle = .none
            return safeCell
            
        default:
            fatalError("Failed to instantiate the table view cell for detail view controller")
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
}

