//
//  FillableTextViewStringExtension.swift
//  Pods
//
//  Created by Vy Nguyen on 3/17/19.
//

import Foundation

public extension String {
    
    static var longSpaceChar: String = " " // A long space (U+2003)
    static var hairSpaceChar: String = " " // A Hair Space (U+200A)
    
    static func longSpaceCharByLengh(length: Int) -> String {
        if length == 0 {
            return ""
        } else if length == 1 {
            return longSpaceChar
        } else if length % 2 == 0 {
            return longSpaceCharByLengh(length: length/2) + longSpaceCharByLengh(length: length/2)
        } else {
            return longSpaceCharByLengh(length: length/2) + longSpaceCharByLengh(length: length/2) + longSpaceChar
        }
    }
    
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
    
    func replacingCharacters(byRegex: String, with: String) -> String {
        guard let regularExpression = try? NSRegularExpression(pattern: byRegex, options: NSRegularExpression.Options.caseInsensitive) else {
            return self
        }
        let range = NSMakeRange(0, self.count)
        return regularExpression.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: with)
    }
}
