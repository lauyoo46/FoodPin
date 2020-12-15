//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 15/12/2020.
//

import UIKit

class ReviewViewController: UIViewController {
    
    @IBOutlet var rateButtons: [UIButton]!
    @IBOutlet var backgroundImageView: UIImageView!
    var restaurant = Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurBackgroundImage()
        makeButtonsInvisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [], animations: {
            self.rateButtons[0].alpha = 1
            self.rateButtons[0].transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.15, options: [], animations: {
            self.rateButtons[1].alpha = 1
            self.rateButtons[1].transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [], animations: {
            self.rateButtons[2].alpha = 1
            self.rateButtons[2].transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.25, options: [], animations: {
            self.rateButtons[3].alpha = 1
            self.rateButtons[3].transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.3, options: [], animations: {
            self.rateButtons[4].alpha = 1
            self.rateButtons[4].transform = .identity
        }, completion: nil)
    }
    
    func makeButtonsInvisible() {
        let moveRightTransform = CGAffineTransform.init(translationX: 600, y: 0)
        let scaleUpTransform = CGAffineTransform.init(scaleX: 5.0, y: 5.0)
        let moveScaleTransform = scaleUpTransform.concatenating(moveRightTransform)
        for rateButton in rateButtons {
            rateButton.transform = moveScaleTransform
            rateButton.alpha = 0
        }
    }
    
    func blurBackgroundImage() {
        backgroundImageView.image = UIImage(named: restaurant.image)
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
    }
    
}
