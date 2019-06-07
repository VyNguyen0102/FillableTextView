//
//  FillableTextViewUIViewExtension.swift
//  FillableTextView
//
//  Created by iOS Dev on 5/27/19.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
