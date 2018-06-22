//
//  WebKitViewController.swift
//  GeolocationApp
//
//  Created by KP on 19/06/2018.
//  Copyright © 2018 KP. All rights reserved.
//

import UIKit
import WebKit

class WebKitViewController: UIViewController {
    
    // Outlet
    @IBOutlet weak var locationWebViewContainer: UIView!
    var locationWebView: WKWebView!
    
    override func loadView() {
        super.loadView()
        
        let contentController = WKUserContentController();
        
        // Call JavaScript Event when web page document finish
        let userScript = WKUserScript(
            source: "swiftEventHandler()",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        
        
        // Register JavaScript webkit.messageHandlers
        contentController.add(self, name: "customCallbackHandlerStart")
        contentController.add(self, name: "customCallbackHandlerStop")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.locationWebView = WKWebView(
            frame: self.locationWebViewContainer.bounds,
            configuration: config
        )
        
        self.locationWebViewContainer.addSubview(self.locationWebView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "js_send_location_to_native", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let req = URLRequest(url: url)
        locationWebView.load(req)
    }
    
    // Call JavaScript Event
    @IBAction func fireJavaScriptAction(_ sender: UIButton) {
        locationWebView.evaluateJavaScript("recieveEventFromSwift()", completionHandler: nil)
    }
}

extension WebKitViewController: WKScriptMessageHandler {
    
    // Handler Event send from JavaScript
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "customCallbackHandlerStart") {
            print("JavaScript is sending a message \(message.body)\n\n")
            
            guard let location = message.body as?  [String: Any] else  { return }
            
            let latitude = location["latitude"] as! Double
            let longitude = location["longitude"] as! Double
            
            print("Running....! We are getting location from javascript: \nLatitude: \(latitude)\nLongitude: \(longitude)")
        }else if message.name == "customCallbackHandlerStop" {
            print("JavaScript is sending a message \(message.body)")
        }
    }
}
