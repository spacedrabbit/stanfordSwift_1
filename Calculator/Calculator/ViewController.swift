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
        operandStack = [Double]()
    }
    
    // this action handles all digit & . presses
    @IBAction func appendDigit(sender: UIButton) {
        
        var digit = sender.currentTitle!
        
        if let constantValue = valueForConstant(digit) {
            
            if userIsTypingANumber { enterKey() } // clears display and adds value to operand stack
            
            digit = "\(constantValue)"
            display.text = digit
            enterKey()
            
            return // exits early since a constant involves displaying a value
                   // and then immediately adding it to the stack, whereas a operand
                   // may be followed by more operands
        }
        
        /* 
            essentially, userIsTypingANumber is also a check for
            whether the first character has been entered. this is why
            we can check for "." at this point in order to correctly display
            the decimal value when a user begins an operand by typing "."
        */
        if userIsTypingANumber {
            //if a decimal already exists, and the "." button is pressed
            if display.text?.rangeOfString(".") != nil && digit == "."{ return }
            display.text = display.text! + digit
            
        } else {
            display.text = (digit == ".") ? "0." : digit // prefixes a value < 0 with 0.
            userIsTypingANumber = true
        }
    }
    
    func valueForConstant(symbol: String) -> Double? {
        let allConstants = Set.init(knownConstants.keys.array)
        return allConstants.contains(symbol) ? knownConstants[symbol] : nil;
    }
    
    @IBAction func operate(sender: UIButton) {

        if userIsTypingANumber{
            enterKey()
        }

        if let operation = sender.currentTitle {
        	addActionToHistory(operation)
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0.0
                // homework #2
            }
        }
    }

	// for displaying operand/operator history, will not work if history is too long
    func addActionToHistory(additionalText: String){
        if let currentHistory = self.history.text {
           self.history.text = currentHistory + "\n" + additionalText
        }
    }

    var operandStack = [Double]() //older

    @IBAction func enterKey() {
        userIsTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
            addActionToHistory("\(displayValue)") //older
        	operandStack.append(displayValue) //older
        	println("operand stack = \(operandStack)") //older
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

