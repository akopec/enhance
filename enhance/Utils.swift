//
//  Utils.swift
//  enhance
//
//  Created by Jeff Hodsdon on 12/24/15.
//  Copyright © 2015 Jeff Hodsdon. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    class func centerView(view: UIView) {
        view.frame = CGRect(x: (kScreenWidth / 2.0) - (view.frame.width / 2.0), y: (kScreenHeight / 2.0) - (view.frame.height / 2.0), width: view.frame.width, height: view.frame.height)
    }
    
    class func changeFrameX(view: UIView, value: CGFloat) {
        view.frame = CGRect(x: value, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
    }
    
    class func changeFrameY(view: UIView, value: CGFloat) {
        view.frame = CGRect(x: view.frame.origin.x, y: value, width: view.frame.width, height: view.frame.height)
    }
    
    class func changeFrameWidth(view: UIView, value: CGFloat) {
        view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: value, height: view.frame.height)
    }
    
    class func changeFrameHeight(view: UIView, value: CGFloat) {
        view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: value)
    }
    
    class func sendAnalyticEvent(name: String) {
        guard let event = GAIDictionaryBuilder.createEvent(withCategory: "action", action: name, label: "", value: NSNumber(value: 0)) else { return }
        GAI.sharedInstance().defaultTracker.send(event.build() as [NSObject : AnyObject])
    }
    
}

extension String {
    
    func escapeStr() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
}

extension String {
    
    func URLEncodedString() -> String? {
        let customAllowedSet =  NSCharacterSet.urlQueryAllowed
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString
    }
    static func queryStringFromParameters(parameters: Dictionary<String,String>) -> String? {
        if (parameters.count == 0)
        {
            return nil
        }
        var queryString : String? = nil
        for (key, value) in parameters {
            if let encodedKey = key.URLEncodedString() {
                if let encodedValue = value.URLEncodedString() {
                    if queryString == nil
                    {
                        queryString = "?"
                    }
                    else
                    {
                        queryString! += "&"
                    }
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        return queryString
    }
}
