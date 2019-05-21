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

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "meo meo []"
        textView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print("ℹ️ \(textView.text)")
    }
}

