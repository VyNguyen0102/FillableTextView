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
        textView.text = "Once upon a time there [] (live) a man called Damocles. A friend of his eventually [] (become) the ruler of a small city. Damocles thought, ‘How lucky my friend [] (be). He [] (be) now a ruler. He must [] (have) a great time. He [] have fine clothes, lots of money and a number of servants. I wish I [] (have) his luck.’ He [] (decide) to visit his friend to enjoy his hospitality. When he []  (reach) the palace, the king himself [] (receive) him with respect and affection. Damocles then [] (tell) the king that he [] (be) indeed a lucky man. The king [] (smile). He [] (invite) his friend to have dinner with him."
        textView.delegate = self
        japaneseTextView.text = "わたしは日本語 「」 すきです。"
        japaneseTextView.delegate = self
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

