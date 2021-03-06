//
//  FillableTextViewModel.swift
//  Pods
//
//  Created by Vy Nguyen on 3/17/19.
//

import Foundation
import UIKit

public enum BlankType {
    case box
    case line
}

public protocol FillableOptionItem {
    func getText() -> String
    func getValue() -> String
}

public struct SimpleFillableOptionItem: FillableOptionItem {
    public let id: Int?
    public let text: String
    public init(text: String) {
        self.id = nil
        self.text = text
    }
    public init(id: Int?, text: String) {
        self.id = id
        self.text = text
    }
    public func getText() -> String {
        return text
    }
    public func getValue() -> String {
        return text
    }
}

public struct TextSpace {
    let placeHolderLength: Int
    let range: NSRange
    let rects: [CGRect]
    let rawText: String
    var replaceText: String {
        if self.text.isEmpty {
            return rawText.replacingOccurrences(of: String.hairSpaceChar, with: String.longSpaceChar)
        } else {
            return rawText.replacingOccurrences(of: String.longSpaceChar, with: String.hairSpaceChar)
        }
    }
    var text: String {
        let start = rawText.index(rawText.startIndex, offsetBy: 1)
        let end = rawText.index(rawText.endIndex, offsetBy: -( placeHolderLength + 1))
        let range = start..<end
        
        let textString = rawText[range]
        return String(textString)
    }
    
    var textRange: NSRange {
        return NSRange.init(location: range.location + 1, length: range.length - ( placeHolderLength + 2))
    }
    
    var editableTextRange: NSRange {
        return NSRange.init(location: range.location + 1, length: range.length - ( placeHolderLength + 1))
    }
    
    var isNeedUpdatePlaceHolder: Bool {
        return text.isEmpty != rawText.contains(String.longSpaceChar)
    }
    
    func isInclude(range: NSRange) -> Bool {
        if self.editableTextRange.contains(range.location) && self.editableTextRange.contains(range.location + range.length) {
            return true
        }
        return false
    }
}

extension Array where Element == TextSpace {
    
    var isNeedUpdatePlaceHolder: Bool {
        return self.contains(where: { $0.isNeedUpdatePlaceHolder })
    }
    
    func getItemAt(range: NSRange) -> TextSpace? {
        return first(where: { item in
            return item.range.contains(range.location - 1) && item.range.contains(range.location + range.length)
        })
    }
    
    func getCurrentRangeIndex(range: NSRange) -> Int? {
        return self.firstIndex { item in
            return item.range.contains(range.location - 1) && item.range.contains(range.location + range.length)
        }
    }
    
    func getNextItemAt(range: NSRange) -> TextSpace? {
        guard let currentIndex = getCurrentRangeIndex(range: range) else {
            return nil
        }
        if self.indices.contains(currentIndex + 1) {
            return self[currentIndex + 1]
        }
        return nil
    }
    
    func isInclude(range: NSRange) -> Bool {
        for item in self {
            if item.isInclude(range: range) {
                return true
            }
        }
        return false
    }
    
    func isEnableDelete(range: NSRange) -> Bool {
        for item in self {
            if item.textRange.contains(range.location) && item.textRange.contains(range.location + range.length - 1) {
                return true
            }
        }
        return false
    }
    
    func isEditable(range: NSRange) -> (Bool, Bool) {
        for item in self {
            if item.range.contains(range.location) && item.range.contains(range.location + range.length - 1) {
                return (true, item.textRange.location == range.location )
            }
        }
        return (false, false)
    }
    
    func itemAtTouchPoint(touchPoint: CGPoint) -> (Int, TextSpace)? {
        for index in 0..<self.count {
            let space = self[index]
            for rect in space.rects {
                if rect.contains(touchPoint) {
                    return (index, space)
                }
            }
        }
        return nil
    }
}

enum RectangleType {
    init(index: Int, itemCount: Int) {
        if itemCount <= 1 {
            self = .full
        } else if index == 0 {
            self = .left
        } else if index == (itemCount - 1) {
            self = .right
        } else {
            self = .mid
        }
    }
    case full
    case left
    case right
    case mid

    var roundingCorners: UIRectCorner {
        switch self {
        case .full:
            return [UIRectCorner.topLeft, .topRight, .bottomRight, .bottomLeft]
        case .left:
            return [UIRectCorner.topLeft, .bottomLeft]
        case .right:
            return [UIRectCorner.topRight, .bottomRight]
        case .mid:
            return []
        }
    }
    
    func rectPath(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return RectangleType.rectPath(rect: rect, cornerRadius: cornerRadius, roundingCorners: self.roundingCorners)
    }
    
    static func rectPath(rect: CGRect, cornerRadius: CGFloat, roundingCorners: UIRectCorner) -> CGPath {
        let path: UIBezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        return path.cgPath
    }
    
    func clipRect(rect: CGRect) -> [CGPath] {
        switch self {
        case .full:
            return []
        case .left:
            return [clipRight(rect: rect)]
        case .right:
            return [clipLeft(rect: rect)]
        case .mid:
            return [clipLeft(rect: rect), clipRight(rect: rect)]
        }
    }
    
    private func clipLeft(rect: CGRect) -> CGPath {
        let path = UIBezierPath.init()
        path.move(to: rect.origin)
        path.addLine(to: CGPoint.init(x: rect.origin.x, y: rect.origin.y + rect.height))
        path.close()
        return path.cgPath
    }
    
    private func clipRight(rect: CGRect) -> CGPath {
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: rect.origin.x + rect.width, y: rect.origin.y))
        path.addLine(to: CGPoint.init(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height))
        path.close()
        return path.cgPath
    }
}
