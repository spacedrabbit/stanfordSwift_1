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
        
        let operation = sender.currentTitle!
        if userIsTypingANumber{
            enterKey()
        }
    
        addActionToHistory(operation)
        
        switch operation {
            
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
            
        // these two math() functions are explained in BSD man pages
        case "cos": performOperation { __cospi($0 / 180) }
        case "sin": performOperation { __sinpi($0 / 180) }
            
        default:
            println("Unknown case encountered")
        }
        
    }
    
    // for displaying operand/operator history, will not work if history is too long
    func addActionToHistory(additionalText: String){
        if let currentHistory = self.history.text {
           self.history.text = currentHistory + "\n" + additionalText
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double){
        if operandStack.count >= 2{
            
            let op1 = operandStack.removeLast()
            let op2 = operandStack.removeLast()
            
            displayValue = operation(op1, op2)
            enterKey()
        }
    }
    
    private func performOperation(operation: Double -> Double){
        if operandStack.count >= 1{
            
            let op1 = operandStack.removeLast()
            
            displayValue = operation(op1)
            enterKey()
        }
    }
    
    var operandStack = [Double]()
    
    @IBAction func enterKey() {
        userIsTypingANumber = false
        addActionToHistory("\(displayValue)")
        operandStack.append(displayValue)
        println("operand stack = \(operandStack)")
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

