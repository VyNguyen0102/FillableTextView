//
//  FillableTextViewActionSheetExtension.swift
//  FBSnapshotTestCase
//
//  Created by iOS Dev on 5/27/19.
//

import Foundation
import UIKit

extension FillableTextView {
    public func showActionSheetAtIndex(_ index: Int, array: [String: Any?]) {
        guard array.count > 0 else {
            return
        }
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for item in array {
            let deleteAction = UIAlertAction(title: item.key, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.setValueForIndex(index, value: item.key)
                self.fillableTextViewDelegate?.didSelectOptionForIndex(index, text: item.key, userData: item.value)
            })
            optionMenu.addAction(deleteAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        self.parentViewController?.present(optionMenu, animated: true, completion: nil)
    }
    public func setValueForIndex(_ index: Int, value: String) {
        guard textSpaces.indices.contains(index) else {
            return
        }
        let textSpace = textSpaces[index]
        
        fillableText = (fillableText as NSString?)?.replacingCharacters(in: textSpace.textRange , with: value)
        self.isEditing = false
    }
}

