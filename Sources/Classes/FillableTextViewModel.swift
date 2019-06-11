//
//  FillableTextViewModel.swift
//  Pods
//
//  Created by Vy Nguyen on 3/17/19.
//

import Foundation
import UIKit

public struct TextSpace {
    let range: NSRange
    let rects: [CGRect]
    let text: String
    
    var textRange: NSRange {
        return NSRange.init(location: range.location + 1, length: range.length - 3)
    }
    
    var editableTextRange: NSRange {
        return NSRange.init(location: range.location + 1, length: range.length - 2)
    }
    
    func isInclude(range: NSRange) -> Bool {
        if self.editableTextRange.contains(range.location) && self.editableTextRange.contains(range.location + range.length) {
            return true
        }
        return false
    }
}

extension Array where Element == TextSpace {
    
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
        let path: UIBezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: self.roundingCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
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
