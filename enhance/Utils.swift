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
        view.frame = CGRectMake((kScreenWidth / 2.0) - (view.frame.width / 2.0), (kScreenHeight / 2.0) - (view.frame.height / 2.0), view.frame.width, view.frame.height)
    }
    
    class func changeFrameX(view: UIView, value: CGFloat) {
        view.frame = CGRectMake(value, view.frame.origin.y, view.frame.width, view.frame.height)
    }
    
    class func changeFrameY(view: UIView, value: CGFloat) {
        view.frame = CGRectMake(view.frame.origin.x, value, view.frame.width, view.frame.height)
    }
    
    class func changeFrameWidth(view: UIView, value: CGFloat) {
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, value, view.frame.height)
    }
    
    class func changeFrameHeight(view: UIView, value: CGFloat) {
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.width, value)
    }
    
    class func sendAnalyticEvent(name: String) {
        let event = GAIDictionaryBuilder.createEventWithCategory("action", action: name, label: "", value: NSNumber(int: 0))
        GAI.sharedInstance().defaultTracker.send(event.build() as [NSObject : AnyObject])
    }
    
}

extension String {
    
    func escapeStr() -> String {
        let raw: NSString = self
        let str = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,raw,"[].",":/?&=;+!@#$()',*",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
        return str as String
    }
}

extension String {
    
    func URLEncodedString() -> String? {
        let customAllowedSet =  NSCharacterSet.URLQueryAllowedCharacterSet()
        let escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
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