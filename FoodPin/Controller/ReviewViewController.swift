//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 15/12/2020.
//

import UIKit

class ReviewViewController: UIViewController {
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var rateButtons: [UIButton]!
    @IBOutlet var backgroundImageView: UIImageView!
    var restaurant: RestaurantMO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurBackgroundImage()
        makeButtonsInvisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [], animations: {
            self.closeButton.alpha = 1
            self.closeButton.transform = .identity
        }, completion: nil)
        
        var delay = 0.1
        for i in 0...4 {
            UIView.animate(withDuration: 0.4, delay: delay, options: [], animations: {
                self.rateButtons[i].alpha = 1
                self.rateButtons[i].transform = .identity
            }, completion: nil)
            delay += 0.05
        }
    }
    
    func makeButtonsInvisible() {
        let moveRightRatingsTransform = CGAffineTransform.init(translationX: 600, y: 0)
        let scaleUpRatingsTransform = CGAffineTransform.init(scaleX: 5.0, y: 5.0)
        let moveScaleRatingsTransform = scaleUpRatingsTransform.concatenating(moveRightRatingsTransform)
        for rateButton in rateButtons {
            rateButton.transform = moveScaleRatingsTransform
            rateButton.alpha = 0
        }
        
        let moveTopCloseTransform = CGAffineTransform.init(translationX: 0, y: -600)
        let scaleUpCloseTransform = CGAffineTransform.init(scaleX: 5.0, y: 5.0)
        let moveScaleCloseTransform = scaleUpCloseTransform.concatenating(moveTopCloseTransform)
        closeButton.alpha = 0
        closeButton.transform = moveScaleCloseTransform
    }
    
    func blurBackgroundImage() {
        guard let restaurantImage = restaurant?.image else {
            return
        }
        backgroundImageView.image = UIImage(data: restaurantImage as Data)
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
    }
    
}
