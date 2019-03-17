//
//  FillableTextView.swift
//  FBSnapshotTestCase
//
//  Created by Vy Nguyen on 3/17/19.
//

import Foundation
import UIKit
import CoreGraphics

class FillableTextView: UITextView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.commonInit()
    }

    func commonInit(){
        self.isEditable = false
        self.isSelectable = false
        self.delegate = self
    }
    fileprivate weak var delegateInterceptor: UITextViewDelegate?
    override var delegate: UITextViewDelegate? {
        didSet {
            if !(delegate?.isEqual(self) ?? true) {
                delegateInterceptor = delegate
            } else {
                delegateInterceptor = nil
            }
            super.delegate = self
        }
    }

    var isEditing: Bool = false {
        didSet {
            if isEditing {
                self.isSelectable = true
                self.isEditable = true
                self.becomeFirstResponder()
            } else {
                self.resignFirstResponder()
                self.isSelectable = false
                self.isEditable = false
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        fillableText = text
    }
    @IBInspectable var beginChar: String = "["
    @IBInspectable var endChar: String = "]"

    @IBInspectable var frameColor: UIColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    @IBInspectable var frameSelectedColor: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    @IBInspectable var frameCornerRadius: CGFloat = 3.0
    @IBInspectable var frameLineWidth: CGFloat = 1.0
    @IBInspectable var frameHeightMultiple: CGFloat = 1.1
    @IBInspectable var fillTextColor: UIColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)

    var blankString: String {
        return "\(beginChar)\(endChar)"
    }

    var blankSpaceRegex: String {
        return "\\\(beginChar)[^\\\(endChar)]*\\\(endChar)"
    }
    var blankSpaceChars: String {
        return "[\\\(beginChar)\\\(endChar)]"
    }
    var textAttributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = frameHeightMultiple
        return [NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 15.0),
                NSAttributedString.Key.foregroundColor : self.textColor ?? UIColor.black,
                NSAttributedString.Key.paragraphStyle: paragraphStyle]
    }
    var editTextAttributes: [NSAttributedString.Key: Any] {
        return [NSAttributedString.Key.foregroundColor: fillTextColor]
    }
    var blankSpaceCharsAttributes: [NSAttributedString.Key: Any] {
        return [NSAttributedString.Key.foregroundColor: UIColor.clear]
    }
    var textFillResult: String? {
        return fillableText?.replacingOccurrences(of: blankSpaceChars, with: "", options: .regularExpression)
    }
    var rectLayers = [CAShapeLayer]()

    var isNeedUpdateTextAttribute = false
    @IBInspectable var fillableText: String? {
        set {
            if let newValue = newValue{
                setAttributedText(fillableText: newValue)
            }
        }
        get {
            return self.attributedText.string
        }
    }
    func setAttributedText(fillableText: String) {
        let attributedText = NSMutableAttributedString(string: fillableText, attributes: textAttributes)
        let placeHolderChars = fillableText.matches(for: blankSpaceChars)
        for item in placeHolderChars {
            attributedText.addAttributes(blankSpaceCharsAttributes, range: item.range)
        }
        self.attributedText = attributedText
        self.updateTextAttributes()
        self.drawRect()
    }
    var textSpaces: [TextSpace] {
        guard let fillableText = fillableText else {
            return []
        }
        let placeHoldersText = fillableText.matches(for: blankSpaceRegex )
        return placeHoldersText.map { space in
            let range = space.range

            var text = fillableText.getTextByRange(range: range) ?? ""
            text = text.replacingOccurrences(of: blankSpaceChars, with: "", options: .regularExpression)
            let textFrames = self.getFramesByRange(range: range)
            return TextSpace.init(range: range, rects: textFrames, text: text)
        }
    }
    var filledText: [String] {
        return textSpaces.map({$0.text})
    }
    func getFramesByRange(range: NSRange) -> [CGRect] {
        guard let textRange = self.getTextRangeBy(range: range) else {
            return []
        }
        guard let selectionRects: [UITextSelectionRect] = self.selectionRects(for: textRange) as? [UITextSelectionRect] else {
            return []
        }

        let rects = (selectionRects.map{ selectionRect in
            return CGRect.init(x: selectionRect.rect.origin.x, y: selectionRect.rect.origin.y + (selectionRect.rect.height * (frameHeightMultiple - 1)) , width: selectionRect.rect.width, height: selectionRect.rect.height / frameHeightMultiple)
        }).filter({ rect in
            rect.width > 0
        })
        return rects
    }

    override public var text: String? {
        didSet {
            fillableText = text
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isSelectable = false
        self.isEditable = false
        guard let touchPoint = touches.first?.location(in: self) else {
            return
        }
        if let space = textSpaces.itemAtTouchPoint(touchPoint: touchPoint) {
            self.isEditing = true
            self.selectedRange = space.textRange
        }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if !textSpaces.isInclude(range: textView.selectedRange) && !isNeedUpdateTextAttribute {
            self.isEditing = false
        } else {
            self.isEditing = true
        }
        self.drawRect()
        delegateInterceptor?.textViewDidChangeSelection?(textView)
    }

    func drawRect(isEndEditing: Bool = false) {
        for layer in rectLayers {
            layer.removeFromSuperlayer()
        }
        rectLayers.removeAll()
        for space in textSpaces {
            let color = (space.isInclude(range: self.selectedRange) && !isEndEditing) ? frameColor : frameSelectedColor
            for index in 0..<space.rects.count {
                let rect = space.rects[index]
                let type = RectangleType.init(index: index, itemCount: space.rects.count)
                drawRect(view: self, at: rect, color: color, type: type)
            }
        }
    }

    func drawRect(view: UIView, at rect: CGRect, color: UIColor, type: RectangleType) {
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.path = type.rectPath(rect: rect,cornerRadius: frameCornerRadius)
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = frameLineWidth
        shapeLayer.fillColor = color.withAlphaComponent(0.1).cgColor
        for clipPath in type.clipRect(rect: rect) {
            let clipLayer: CAShapeLayer = CAShapeLayer()
            clipLayer.path = clipPath
            clipLayer.lineWidth = frameLineWidth
            clipLayer.strokeColor = self.backgroundColor?.cgColor
            shapeLayer.addSublayer(clipLayer)
        }
        rectLayers.append(shapeLayer)
        view.layer.insertSublayer(shapeLayer, at: 0) //.addSublayer(shapeLayer, at: 0)
    }
    func updateTextAttributes() {
        guard let text = self.attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        for space in textSpaces {
            text.addAttributes(editTextAttributes, range: space.textRange)
        }
        let lastSelection = selectedRange // Keep old selection
        self.attributedText = text.copy() as? NSAttributedString
        self.selectedRange = lastSelection
        isNeedUpdateTextAttribute = false
    }

    override func selectAll(_ sender: Any?) {
        guard let space = textSpaces.getItemAt(range: self.selectedRange) else {
            super.selectAll(sender)
            return
        }
        self.selectedRange = space.textRange
    }
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.origin.y += (rect.size.height * (frameHeightMultiple - 1))
        return rect
    }
    func getRangeBy(textRange: UITextRange) -> NSRange {
        let begining = self.beginningOfDocument
        let selectionStart = textRange.start
        let selectionEnd = textRange.end

        let location = self.offset(from: begining, to: selectionStart)
        let length = self.offset(from: selectionStart, to: selectionEnd)

        return NSRange.init(location: location, length: length)
    }
    func getTextRangeBy(range: NSRange) -> UITextRange? {
        // text position of the range.location
        let start = self.position(from: self.beginningOfDocument, offset: range.location)!
        // text position of the end of the range
        let end = self.position(from: start, offset: range.length)!
        // text range of the range
        return self.textRange(from: start, to: end)
    }

    override func canPaste(_ itemProviders: [NSItemProvider]) -> Bool {
        print("can paste: false")
        return false
    }
}
extension FillableTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if isNeedUpdateTextAttribute {
            self.updateTextAttributes()
        }
        drawRect()
        delegateInterceptor?.textViewDidChange?(textView)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.contains(beginChar) || text.contains(endChar) || !textSpaces.isInclude(range: range) {
            return false
        }
        if text == "\n" {
            guard let space = textSpaces.getNextItemAt(range: self.selectedRange) else {
                self.isEditing = false
                return false
            }
            self.selectedRange = space.textRange
            return false
        }
        if text.isEmpty && textSpaces.isEnableDelete(range: range) {
            return delegateInterceptor?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
        } else if (text.count > 0) {
            let (isEditable, isNeedUpdateTextAttribute) = textSpaces.isEditable(range: range)
            self.isNeedUpdateTextAttribute = isNeedUpdateTextAttribute
            return isEditable
        }
        return false
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegateInterceptor?.textViewShouldBeginEditing?(textView) ?? true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegateInterceptor?.textViewShouldEndEditing?(textView) ?? true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        delegateInterceptor?.textViewDidBeginEditing?(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        delegateInterceptor?.textViewDidEndEditing?(textView)
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegateInterceptor?.textView?( textView, shouldInteractWith: URL, in: characterRange,interaction: interaction) ?? true
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegateInterceptor?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return delegateInterceptor?.textView?( textView, shouldInteractWith: URL, in: characterRange) ?? true
    }

    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        return delegateInterceptor?.textView?( textView, shouldInteractWith: textAttachment, in: characterRange) ?? true
    }
}
