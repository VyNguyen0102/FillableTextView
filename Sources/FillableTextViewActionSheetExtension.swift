//
//  FillableTextViewActionSheetExtension.swift
//  FBSnapshotTestCase
//
//  Created by iOS Dev on 5/27/19.
//

import Foundation
import UIKit

extension FillableTextView {
    public func showActionSheetAtIndex(_ index: Int, array: [FillableOptionItem]) {
        self.isEditable = false
        guard array.count > 0 else {
            return
        }
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for item in array {
            let deleteAction = UIAlertAction(title: item.getText(), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.setValueForIndex(index, value: item.getText())
                self.fillableTextViewDelegate?.didSelectOptionForIndex(self, index: index, text: item.getValue(), userData: item)
                self.drawRect(isEndEditing: true)
            })
            optionMenu.addAction(deleteAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.isEditing = false
            self.drawRect(isEndEditing: true)
        })
        optionMenu.addAction(cancelAction)
        self.parentViewController?.present(optionMenu, animated: true, completion: nil)
    }
    public func setValueForIndex(_ index: Int, value: String) {
        guard textSpaces.indices.contains(index) else {
            return
        }
        let textSpace = textSpaces[index]
        
        fillableAttributedText = (fillableAttributedText as NSString?)?.replacingCharacters(in: textSpace.textRange , with: value)
        self.textViewDidChange(self)
        self.isEditing = false
    }
}

