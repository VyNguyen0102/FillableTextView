//
//  ViewController.swift
//  FillableTextView
//
//  Created by Vy Nguyen on 03/17/2019.
//  Copyright (c) 2019 Vy Nguyen. All rights reserved.
//

import UIKit
import FillableTextView

class ViewController: UIViewController {

    @IBOutlet weak var textView: FillableTextView!
    @IBOutlet weak var japaneseTextView: FillableTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "Once upon a time there[]adfasdf "
        textView.delegate = self
        textView.fillableTextViewDelegate = self
        japaneseTextView.text = "わたしは日本語 「」 すきです。"
        japaneseTextView.delegate = self
        japaneseTextView.fillableTextViewDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print(#function)
        print("ℹ️ \(String(describing: textView.text))")
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        print(textView.selectedRange)
    }
}

extension ViewController: FillableTextViewDelegate {
    func textViewDidChangeText(_ textView: UITextView, index: Int, text: String, textSpace: TextSpace) {
        print("index = \(index) text = \(text)")
    }
    
    func optionsForIndex(_ index: Int) -> [String : Any?]? {
        return ["を": false
            ,"が": true
            ,"も": false]
    }
    
    func didSelectOptionForIndex(_ index: Int, text: String, userData: Any?) {
        print("didSelectOption \(text) with userData \(String(describing: userData))")
    }
}
