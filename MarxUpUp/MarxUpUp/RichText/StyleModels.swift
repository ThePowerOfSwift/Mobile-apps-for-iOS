//
//  StyleModels.swift
//  MarxUpUp
//
//  Created by Ognyanka Boneva on 13.03.19.
//  Copyright © 2019 Ognyanka Boneva. All rights reserved.
//

import UIKit

class StyleItem {
    let type: StyleType
    let value: Any
    var range: NSRange

    init(_ type: StyleType, _ value: Any, _ range: NSRange) {
        self.type = type
        self.value = value
        self.range = range
    }

    convenience init(shadowFromDict dict: [String: String], withRange range: NSRange) {
        let shadow = NSShadow.init()

        if let colorString = dict[XMLElement.color.rawValue] {
            shadow.shadowColor = UIColor(fromHEX: colorString)
        }

        if let offsetH = CGFloat(fromDict: dict, forKey: XMLElement.offsetHeight.rawValue),
            let offsetW = CGFloat(fromDict: dict, forKey: XMLElement.offsetWidth.rawValue) {
            shadow.shadowOffset = CGSize(width: offsetW, height: offsetH)
        }

        if let blur = CGFloat(fromDict: dict, forKey: XMLElement.blur.rawValue) {
            shadow.shadowBlurRadius = blur
        }

        self.init(.shadow, shadow, range)
    }

    var valueAsString: String {
        if self.type.isColor {
            let color = self.value as! UIColor
            return color.hex
        } else if self.type.isLine {
            let line = self.value as! NSUnderlineStyle
            return line.stringValue
        } else if self.type == .link {
            return String(self.value as! NSString)
        } else if self.type == .strokeWidth {
            let width = self.value as! CGFloat
            return width.stringValue
        }
        return ""
    }

    convenience init(fontFromDict dict: [String: String], withRange range: NSRange) {
        if let fontName = dict[XMLElement.name.rawValue],
            let size = CGFloat(fromDict: dict, forKey: XMLElement.size.rawValue),
            let font = UIFont(name: fontName, size: size) {
            self.init(.font, font as Any, range)
        } else {
            self.init(.font, UIFont.systemFont(ofSize: UIFont.systemFontSize) as Any, range)
        }
    }
}

extension StyleItem: Equatable {
    func valueIsEqualToValue(_ other: Any) -> Bool {
        if self.type.isColor {
            return self.value as! UIColor == other as! UIColor
        } else if self.type.isLine {
            return self.value as! NSUnderlineStyle == other as! NSUnderlineStyle
        } else if self.type == .font {
            return self.value as! UIFont == other as! UIFont
        } else if self.type == .shadow {
            return self.value as! NSShadow == other as! NSShadow
        } else if self.type == .strokeWidth {
            return self.value as! CGFloat == other as! CGFloat
        } else if self.type == .link {
            return self.value as! NSString == other as! NSString
        }

        return false
    }

    static func == (left: StyleItem, right: StyleItem) -> Bool {
        return left.type == right.type && left.range == right.range && left.valueIsEqualToValue(right.value)
    }
}

class CustomStyle: NSObject {
    var name = ""
    var styleItems = [StyleItem]()
}
