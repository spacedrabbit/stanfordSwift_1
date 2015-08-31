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
    
    // this action handles all digit presses
    @IBAction func appendDigit(sender: UIButton) {
        
        var digit = sender.currentTitle!
        println("digit = \(digit)")

        if userIsTypingANumber {
            display.text = display.text! + digit
        } else {
            if digit == "π" {
                digit = "\(M_PI)"
                enterKey()
            } else {
                userIsTypingANumber = true
            }
            display.text = digit
        }
    }
    
    @IBAction func appendSymbol(sender: UIButton) {
        
        var symbol = sender.currentTitle!
        var value: Double
        var numericString: String
        println("symbol \(symbol)")
        
        if userIsTypingANumber {
            enterKey()
        }
        
        switch symbol {
        case "π":
            value = M_PI
        case "e":
            value = M_E
        default:
            value = 0.0
        }
        
        display.text = "\(value)"
        enterKey()
    }
    
    @IBAction func operate(sender: UIButton) {
        
        let operation = sender.currentTitle!
        if userIsTypingANumber{
            enterKey()
        }
        
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
            println("Stuff")
        }
    }
    
    // this function accepts another function as a argument
    // that function has the signature of taking two Doubles and returning a Double
    func performOperation(operation: (Double, Double) -> Double){
        if operandStack.count >= 2{
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enterKey()
        }
    }
    
    private func performOperation(operation: Double -> Double){
        if operandStack.count >= 1{
            displayValue = operation(operandStack.removeLast())
            enterKey()
        }
    }
    
    var operandStack = [Double]()
    
    @IBAction func enterKey() {
        userIsTypingANumber = false
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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

