//
//  FillableTextView.swift
//  FBSnapshotTestCase
//
//  Created by Vy Nguyen on 3/17/19.
//

import Foundation
import UIKit
import CoreGraphics

public protocol FillableTextViewDelegate: class {
    func optionsForIndex(_ textView: FillableTextView, index: Int) -> [FillableOptionItem]?
    func didSelectOptionForIndex(_ textView: FillableTextView, index: Int, text: String, userData: FillableOptionItem)
    func textViewDidChangeText(_ textView: FillableTextView, index: Int, text: String, textSpace: TextSpace)
}

public class FillableTextView: UITextView {
    
    @IBInspectable public var maxLengh: Int = 15
    
    @IBInspectable public var beginChar: String = "["
    @IBInspectable public var endChar: String = "]"
    
    @IBInspectable public var placeHolderLength: Int = 2 {
        didSet {
             fillableText = rawText
        }
    }
    
    @IBInspectable public var frameColor: UIColor = #colorLiteral(red: 0.1769979828, green: 0.1916395839, blue: 0.2129101933, alpha: 0.5)
    @IBInspectable public var frameSelectedColor: UIColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 0.5)
    @IBInspectable public var frameBackgroundColor: UIColor = #colorLiteral(red: 0.77581623, green: 0.8399931859, blue: 0.9332263616, alpha: 0.5)
    @IBInspectable public var frameSelectedBackgroundColor: UIColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 0.09738869863)
    @IBInspectable public var frameCornerRadius: CGFloat = 3.0
    @IBInspectable public var frameLineWidth: CGFloat = 1.0
    @IBInspectable public var frameHeightMultiple: CGFloat = 1.1
    @IBInspectable public var fillTextColor: UIColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
    
    public var blankType: BlankType = .box {
        didSet {
            self.drawRect()
        }
    }
    
    public weak var fillableTextViewDelegate: FillableTextViewDelegate?
    
    var rawText: String?
    
    var lastedSelectedRange: NSRange?
    
    @IBInspectable var fillableText: String? {
        set {
            if let newValue = newValue {
                fillableAttributedText = insertPlaceHolderToString(text: newValue)
            }
        }
        get {
            return self.attributedText.string
        }
    }
    
    var fillableAttributedText: String? {
        set {
            if let newValue = newValue {
                lastedSelectedRange = self.selectedRange
                setAttributedText(fillableText: newValue)
                if let lastedSelectedRange = lastedSelectedRange {
                    self.selectedRange = lastedSelectedRange
                    self.lastedSelectedRange = nil
                }
            }
        }
        get {
            return self.attributedText.string
        }
    }
    
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
    
    weak var delegateInterceptor: UITextViewDelegate?
    override public var delegate: UITextViewDelegate? {
        willSet {
            if isDelegateConfigured {
                delegateInterceptor = newValue
            }
        }
        didSet {
            if !isDelegateConfigured {
                self.delegate = self
            }
        }
    }
    
    fileprivate var isDelegateConfigured: Bool {
        return delegate?.isEqual(self) ?? false
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
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        fillableText = text
    }

    fileprivate var emptySpaceRegex: String {
        return " ?\\\(beginChar)\\\(endChar) ?"
    }
    
    fileprivate var defaultSpaceRegex: String {
        return " \(beginChar)\(endChar) "
    }

    fileprivate var blankSpaceRegex: String {
        return "\\\(beginChar)[^\\\(endChar)]*\\\(endChar)"
    }
    
    fileprivate var blankSpaceChars: String {
        return "[\\\(beginChar)\\\(endChar)\(String.longSpaceChar)\(String.hairSpaceChar)]"
    }
    
    lazy var textAttributes: [NSAttributedString.Key: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = frameHeightMultiple
        return [NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 15.0),
                NSAttributedString.Key.foregroundColor : self.textColor ?? UIColor.black,
                NSAttributedString.Key.paragraphStyle: paragraphStyle]
    }()
    
    open var editTextAttributes: [NSAttributedString.Key: Any] {
        return [NSAttributedString.Key.foregroundColor: fillTextColor]
    }
    
    open var blankSpaceCharsAttributes: [NSAttributedString.Key: Any] {
        return [NSAttributedString.Key.foregroundColor: UIColor.clear]
    }
    
    public var textFillResult: String? {
        return fillableText?.replacingOccurrences(of: blankSpaceChars, with: "", options: .regularExpression)
    }
    
    var rectLayers = [CAShapeLayer]()

    fileprivate var isNeedUpdateTextAttribute = false
    
    func insertPlaceHolderToString(text: String) -> String {
        var result = text.replacingCharacters(byRegex: emptySpaceRegex, with: defaultSpaceRegex)
        result = result.replacingOccurrences(of: endChar, with:"\(String.longSpaceCharByLengh(length: placeHolderLength) )\(endChar)" )
        return result
    }
    
    func setAttributedText(fillableText: String) {
        // Repalce blank space with place holder
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
            let rawText = fillableText.getTextByRange(range: range) ?? ""
            let textFrames = self.getFramesByRange(range: range)
            return TextSpace.init(placeHolderLength: self.placeHolderLength, range: range, rects: textFrames, rawText: rawText)
        }
    }
    
    public var selectedTextSpace: TextSpace? {
        return textSpaces.first(where: { $0.isInclude(range: selectedRange)})
    }
    
    public var selectedTextSpaceIndex: Int? {
        return textSpaces.firstIndex(where: { $0.isInclude(range: selectedRange)})
    }
    
    public var filledText: [String] {
        return textSpaces.map({$0.text})
    }
    
    func getFramesByRange(range: NSRange) -> [CGRect] {
        guard let textRange = self.getTextRangeBy(range: range) else {
            return []
        }
        let selectionRects: [UITextSelectionRect] = self.selectionRects(for: textRange)

        let rects = (selectionRects.map{ selectionRect in
            return CGRect.init(x: selectionRect.rect.origin.x, y: selectionRect.rect.origin.y + (selectionRect.rect.height * (frameHeightMultiple - 1)) , width: selectionRect.rect.width, height: selectionRect.rect.height / frameHeightMultiple)
        }).filter({ rect in
            rect.width > 0
        })
        return rects
    }

    override public var text: String? {
        didSet {
            rawText = text
            fillableText = text
        }
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isSelectable = false
        self.isEditable = false
        guard let touchPoint = touches.first?.location(in: self) else {
            return
        }
        if let (index, space) = textSpaces.itemAtTouchPoint(touchPoint: touchPoint) {
            self.isEditing = true
            self.selectedRange = space.textRange
            if let options = fillableTextViewDelegate?.optionsForIndex(self, index: index) , options.count > 0 {
                showActionSheetAtIndex(index, array: options)
            }
        }
    }

    func drawRect(isEndEditing: Bool = false) {
        for layer in rectLayers {
            layer.removeFromSuperlayer()
        }
        rectLayers.removeAll()
        for space in textSpaces {
            let color = (!space.isInclude(range: self.selectedRange) || isEndEditing) ? frameColor : frameSelectedColor
            let bgColor = (!space.isInclude(range: self.selectedRange) || isEndEditing) ? frameBackgroundColor : frameSelectedBackgroundColor
            for index in 0..<space.rects.count {
                let rect = space.rects[index]
                let type = RectangleType.init(index: index, itemCount: space.rects.count)
                switch blankType {
                case .box:
                    drawRect(view: self, at: rect, color: color, bgColor: bgColor, type: type)
                case .line:
                    drawUnderLine(view: self, at: rect, color: color, bgColor: bgColor, type: type)
                }
            }
        }
    }

    fileprivate func drawUnderLine(view: UIView, at rect: CGRect, color: UIColor, bgColor: UIColor, type: RectangleType) {
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.path = type.rectPath(rect: rect,cornerRadius: frameCornerRadius)
        shapeLayer.fillColor = bgColor.cgColor
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: rect.origin.x + frameCornerRadius, y: rect.origin.y + rect.height))
        path.addLine(to: CGPoint.init(x: rect.origin.x + rect.width - frameCornerRadius, y: rect.origin.y + rect.height))
        path.close()

        let clipLayer: CAShapeLayer = CAShapeLayer()
        clipLayer.path = path.cgPath
        clipLayer.lineWidth = frameLineWidth
        clipLayer.strokeColor = color.cgColor
        shapeLayer.addSublayer(clipLayer)
        
        shapeLayer.addSublayer(clipLayer)

        rectLayers.append(shapeLayer)
        view.layer.insertSublayer(shapeLayer, at: 0) //.addSublayer(shapeLayer, at: 0)
    }
    
    fileprivate func drawRect(view: UIView, at rect: CGRect, color: UIColor, bgColor: UIColor, type: RectangleType) {
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.path = type.rectPath(rect: rect,cornerRadius: frameCornerRadius)
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = frameLineWidth
        shapeLayer.fillColor = bgColor.cgColor
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
    
    fileprivate func updateTextAttributes() {
        guard let text = self.attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        for space in textSpaces {
            text.addAttributes(editTextAttributes, range: space.textRange)
        }
        let lastSelection = selectedRange // Keep old selection
        self.attributedText = text.copy() as? NSAttributedString
        self.selectedRange = lastSelection
        isNeedUpdateTextAttribute = false
    }

    override public func selectAll(_ sender: Any?) {
        guard let space = textSpaces.getItemAt(range: self.selectedRange) else {
            super.selectAll(sender)
            return
        }
        self.selectedRange = space.textRange
    }
    
    override public func caretRect(for position: UITextPosition) -> CGRect {
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

    override public func canPaste(_ itemProviders: [NSItemProvider]) -> Bool {
        //TODO
        print("can paste: false")
        return false
    }
}
extension FillableTextView: UITextViewDelegate {
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if !textSpaces.isInclude(range: textView.selectedRange) && !isNeedUpdateTextAttribute {
            self.isEditing = false
        } else {
            self.isEditing = true
        }
        self.drawRect()
        delegateInterceptor?.textViewDidChangeSelection?(textView)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if let updateTextSpace = textSpaces.first(where: {  $0.isNeedUpdatePlaceHolder }) {
            fillableAttributedText = (fillableAttributedText as NSString?)?.replacingCharacters(in: updateTextSpace.range , with: updateTextSpace.replaceText)
        } else {
            if isNeedUpdateTextAttribute {
                self.updateTextAttributes()
            }
            drawRect()
        }
        delegateInterceptor?.textViewDidChange?(textView)
        if let selectedTextSpace = selectedTextSpace, let selectedTextSpaceIndex = selectedTextSpaceIndex {
            fillableTextViewDelegate?.textViewDidChangeText(self, index: selectedTextSpaceIndex, text: selectedTextSpace.text, textSpace: selectedTextSpace)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(#function)
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
            // Check length
            guard let space = textSpaces.getItemAt(range: self.selectedRange),
                let textViewText = textView.text,
                let rangeOfTextToReplace = Range(range, in: textViewText) else {
                return false
            }
            let substringToReplace = textViewText[rangeOfTextToReplace]
            let count = space.text.count + text.count - substringToReplace.count
            if !isEditable || count > self.maxLengh {
                return false
            }
            return delegateInterceptor?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
        }
        return false
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegateInterceptor?.textViewShouldBeginEditing?(textView) ?? true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegateInterceptor?.textViewShouldEndEditing?(textView) ?? true
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegateInterceptor?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        delegateInterceptor?.textViewDidEndEditing?(textView)
    }

    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegateInterceptor?.textView?( textView, shouldInteractWith: URL, in: characterRange,interaction: interaction) ?? true
    }

    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegateInterceptor?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return delegateInterceptor?.textView?( textView, shouldInteractWith: URL, in: characterRange) ?? true
    }

    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        return delegateInterceptor?.textView?( textView, shouldInteractWith: textAttachment, in: characterRange) ?? true
    }
}
