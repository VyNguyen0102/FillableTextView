//
//  ViewController.swift
//  FillableTextView
//
//  Created by Vy Nguyen on 03/17/2019.
//  Copyright (c) 2019 Vy Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        //print(textView.text)
    }
}

