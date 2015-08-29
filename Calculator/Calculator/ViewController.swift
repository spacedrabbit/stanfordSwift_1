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
        
        let operation = sender.currentTitle!
        if userIsTypingANumber{
            enterKey()
        }
        
        switch operation {
            // it is possible to send functions as arguments to other funcitons
            // the receiving function just has to specify what kind of function
            // it allows, much like passing blocks in ObjC
        case "×": performOperation(multiply)
//        case "÷": performOperation()
//        case "+":
//        case "−":
        
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
    
    func multiply(opt1: Double, opt2: Double) -> Double{
        return opt1 * opt2
    }
    
    // because swift is strongly typed, it can perform many type inferences 
    // in this case, our variable declaration could be written as:
    //
    // var operandStack: Array<Double> = Array<Double>()
    //
    // but we can omit the Array<T> before the equals because of that inference
    var operandStack = Array<Double>()
    
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

