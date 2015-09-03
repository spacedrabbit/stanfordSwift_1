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
        } )
        UIView.setAnimationCurve(.EaseIn)
        
        display.text = "0.0"
        history.text = ""
        brain.clearBrain()
    }
    
    // this action handles all digit & . presses
    @IBAction func appendDigit(sender: UIButton) {
        
        var digit = sender.currentTitle!
        
        if let constantValue = valueForConstant(digit) {
            
            if userIsTypingANumber { enterKey() } // clears display and adds value to operand stack
            
            digit = "\(constantValue)"
            display.text = digit
            enterKey()
            return // FIXME: display isn't cleared, so if you press ⏎ after inputting pi, it will
            // and pi again (and again..) to the operand stack
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
            // this needs an if let since .performOperation returns a Double?
            // because we need to account for someone pressing an operator on an empty operand stack
            if let result = brain.performOperation(operation) {
                displayValue = result
            }
        }
    }

    @IBAction func enterKey() {
        
        userIsTypingANumber = false
        if let validValue = displayValue {
            if let result = brain.pushOperand(validValue) {
                displayValue = result
            }
        }
    }
    
    // provides Double value for symbolic constants such as Pi
    func valueForConstant(symbol: String) -> Double? {
        let allConstants = Set.init(knownConstants.keys.array)
        return allConstants.contains(symbol) ? knownConstants[symbol] : nil;
    }
    
    // initializer class
    var displayValue: Double?{
        get {
            let formatter = NSNumberFormatter()
            if let validValue = formatter.numberFromString(display.text!) {
                return validValue.doubleValue
            }
            display.text = "0.0"
            return nil
        }
        set {
            display.text = "\(newValue!)"
            userIsTypingANumber = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.history.numberOfLines = 0
        self.history.textAlignment = .Right
        self.history.text = ""
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

