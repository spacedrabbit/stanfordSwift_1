//
//  ViewController.swift
//  Calculator
//
//  Created by Louis Tur on 8/28/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    var userIsTypingANumber: Bool = false
    var brain = CalculatorBrain()
    
    // this action handles all digit presses
    @IBAction func appendDigit(sender: UIButton) {
        
        // a UIButton's currentTitle property is normally an optional
        // we explicitly unwrap it to be used for our constant here
        let digit = sender.currentTitle!
        println("digit = \(digit)")
        
        if userIsTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsTypingANumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {

        if userIsTypingANumber{
            enterKey()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0.0
                // homework #2
            }
        }
    }

    @IBAction func enterKey() {
        userIsTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            // homework assignment #2
            displayValue = 0.0
        }
    }
    
    // initializer class
    var displayValue: Double{
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            // newValue is a reserved keyword for setters
            display.text = "\(newValue)"
            userIsTypingANumber = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

