//
//  WebViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 22/12/2020.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    var targetURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never

        loadWebPage()
    }
    
    func loadWebPage() {
        if let url = URL(string: targetURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

}
