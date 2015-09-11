//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Louis Tur on 8/29/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    // enums are useful for when some things are related, but they are exclusively
    // one of the associated members -- you can be an Op.Operand, but not an Op.Unary at the
    // same time. In our "operation stack", the values stored in the array will either
    // be an operator or an operand
    
    // Printable: classes or structs: this is a protocol. This enum implements the Printable protocol
    // which just returns a string from the variable .description
    private enum Op: Printable{
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        // a read-only, computed value
        var description: String{
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String: Op]()
    
    init(){
        
        // we put this funciton inside of init because otherwise we'd have to add private to it
        // implement this for hw
//        func learnOp(op: Op){
//            knownOps[op.description] = op
//        }
        
        // these dictionary values match the operations defined in the first and second lecture
        
        // point of focus: binary operators in swift are actually functions that specify that they can be infix
        // so we could rewrite the following as it is below. Note that we cant do this for division or
        // subtraction because we reverse the operands since they are removed from the stack in reverse order
        //        knownOps["×"] = Op.BinaryOperation("×", { $0 * $1 })
        //        knownOps["÷"] = Op.BinaryOperation("÷", { $1 / $0 })
        //        knownOps["+"] = Op.BinaryOperation("+", { $0 + $1 })
        //        knownOps["−"] = Op.BinaryOperation("−", { $1 - $0 })
        
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷", { $1 / $0 })
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−", { $1 - $0 })
        
        //knownOps["√"] = Op.UnaryOperation("√", { sqrt($0) })
        // get this: there is a named function, called sqrt that is Double -> Double
        // so we can simplify our statement as follows
        knownOps["√"] = Op.UnaryOperation("√", sqrt )
    }
    
    var program: AnyObject {
        get {
            return opStack.map{ $0.description } // returns an array for the opStack element descriptions
        }
        set {
            // making sure that the object being passed in is an array of strings
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
            }
        }
    }
    
    // here, were could declare the parameter of evaluate(_:) as a 'var' in order to use a mutable copy
    //      func evaluate(var ops: [Op]) -> (result: Double?, remainingOps: [Op])
    //
    // of the argument passed in, but instead we declare a local variable. Arays and Dictionaries are 
    // structs in swift, so we cannot pass them by reference -- they are passed by value. And since structs
    // cannot be changed after they are declared, you cannot directly alter them
    // Another note: this is 'private' because it takes a private argument
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty{
            
            var remainingOps = ops // this copies the values since it isn't a class. a class would get another reference instead
            let op = remainingOps.removeLast()
            
            switch op {
                
            // if the Op enum is of type .Operand, we just want to return the operand value and the remaining Ops
            // '(let operand):' allows us to access the value of op.Operand and assign it to operand
            case .Operand(let operand):
                return (operand, remainingOps)
                
            // if the Op enum is of type .UnaryOperation, we're intereste in the Op operation, which we assign to 'operation'
            // We make a recursive call to evaluate(_:) passing it the remainingOps and set it to a constant
            // If that constant returns a tuple of (Double? : [Op]) and the .result value isn't nil, we unwrap it for further use
            //
            case .UnaryOperation( _, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    // operation here is of type Double -> Double
                    // So we pass in the operand as the Double parameter, and it will return a Double to satisfy our first
                    // tuple type
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation( _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        
                        // similiar to the above, operation represents (Double, Double) -> Double
                        // So the operation gets passed the two operand Doubles in order to return a Double
                        // to satisfy the first tuple value of evaluate(_:)
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            // There is no need for a default case since op only allows for 3 possible values
            }
        }
        
        return (nil, ops)
    }
    
    // evalutes opStack and return value
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        // this statement effectively says, to add type Op.Operand with value of operand to the opStack
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        // here, operation is really an Optional, because the key we look up may not actually exist or have 
        // a value. So we use an if let to conditionally unwrap it for use
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}