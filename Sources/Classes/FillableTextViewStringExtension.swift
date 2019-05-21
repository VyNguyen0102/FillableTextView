//
//  FillableTextViewStringExtension.swift
//  Pods
//
//  Created by Vy Nguyen on 3/17/19.
//

import Foundation

public extension String {
    
    func matches(for regex: String) -> [NSTextCheckingResult] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func getTextByRange(range: NSRange) -> String? {
        if let textRange = Range.init(range, in: self) {
            return String(self[textRange])
        }
        return nil
    }
}
