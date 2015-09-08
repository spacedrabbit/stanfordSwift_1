//
//  ViewController.swift
//  Calculator
//
//  Created by Louis Tur on 8/28/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

import UIKit

class ViewController : UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    var userIsTypingANumber: Bool = false
    var brain = CalculatorBrain()
    var knownConstants = ["π" : M_PI, "e" : M_E]
    
    @IBAction func clearAll() {
        
        // just some UI feedback to let you know something happened
        display.alpha = 0.0
        UIView.animateWithDuration(0.25, animations: {
            self.display.alpha = 1.0
        })
        UIView.setAnimationCurve(.EaseIn)
        
        display.text = "0.0"
        history.text = ""
        brain.clearBrain()
    }
    
    @IBAction func saveVariableToMemory(sender: UIButton) {
        if let value = displayValue {
            brain.memoryValue = value
            userIsTypingANumber = false
        } else {
            display.text = "Could not save"
        }
    }
    
    @IBAction func retrieveVariableFromMemory(sender: UIButton) {
        if let evaluation = brain.pushOperand(sender.currentTitle!){
            displayValue = evaluation
        } else {
            display.text = "Memory not set"
        }
    }
    
    // this action handles all digit & . presses
    @IBAction func appendDigit(sender: UIButton) {
        
        var digit = sender.currentTitle!
        
        if let constantValue = valueForConstant(digit) {
            
            // clears screen and adds last value to operand stack
            if userIsTypingANumber { enterKey() }
            
            // this now only sends the "π" to the brain
            // what is displayed on screen is the result of evaluate()
            if let result = brain.pushOperand(digit){
                displayValue = result
                println("the result: \(result)")
                userIsTypingANumber = false
            } else {
                displayValue = nil
            }
            // FIXME: display isn't cleared, so if you press ⏎ 
            // after inputting pi, it will add pi again (and again..)
            // to the operand stack
            
            return
        }
        
        if userIsTypingANumber {
            //if a decimal already exists, and the "." button is pressed, return early and do nothing
            if display.text?.rangeOfString(".") != nil && digit == "."{ return }
            display.text = display.text! + digit
            
        } else {
            display.text = (digit == ".") ? "0." : digit // prefixes a value < 0 with 0.
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
                displayValue = nil
            }
        }
        
        history.text = "\(brain)"
    }

    // ---- ENTER KEY ---- //
    @IBAction func enterKey() {
        
        userIsTypingANumber = false
        if let validValue = displayValue {
            if let result = brain.pushOperand(validValue) {
                displayValue = result
            }
            else {
                displayValue = nil
            }
        }
        
        history.text = "\(brain)"
    }
    
    // provides Double value for symbolic constants such as Pi
    func valueForConstant(symbol: String) -> Double? {
        let allConstants = Set.init(knownConstants.keys.array)
        return allConstants.contains(symbol) ? knownConstants[symbol] : nil;
    }
    
    // attempts to always show a valid value, otherwise it returns nil
    var displayValue: Double?{
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            let formatter = NSNumberFormatter()
            if newValue != nil {
                formatter.numberStyle = .DecimalStyle
                formatter.maximumSignificantDigits = 10
                formatter.minimumFractionDigits = 1
                if let stringValue = formatter.stringFromNumber(newValue!){
                    display.text = stringValue
                }
            } else {
                display.text = " "
            }
            
            userIsTypingANumber = false
        }
    }
    
    // ---- inherited methods ---- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

