//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Louis Tur on 8/29/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

import Foundation

class CalculatorBrain: Printable
{
    // enums are useful for when some things are related, but they are exclusively
    // one of the associated members -- you can be an Op.Operand, but not an Op.Unary at the
    // same time. In our "operation stack", the values stored in the array will either
    // be an operator or an operand
    
    private enum Op: Printable{
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        // a read-only, computed value
        var description: String{
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    var memoryValue: Double? {
        get{
            return variableValues["M"]!
        }
        set{
            println("setting the value of memory to: \(newValue)")
            variableValues["M"] = newValue
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String: Op]()
    var variableValues: Dictionary<String, Double?> = ["π" : M_PI, "e" : M_E, "M" : nil]
    
    init(){
        // we put this funciton inside of init because otherwise we'd have to add 'private' to it
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt ))
        learnOp(Op.UnaryOperation("cos", { __cospi($0/180) }))
        learnOp(Op.UnaryOperation("sin", { __sinpi($0/180) }))
        
    }
    
    var description: String{
        get {
            
            var (results, ops ) = ("", opStack)
            
            while ops.count > 0{
                var current: String?
                (current, ops) = buildDescription(ops)
                results = (results == "" ) ? current! : "\(current!), \(results)"
            }
            
            return results
        }
    }
    
    private func buildDescription(ops:[Op]) -> (opDescription: String?, remainingOps: [Op] ){

        if !ops.isEmpty{
            
            var remainingOps = ops
            let lastOp = remainingOps.removeLast()
            
            switch lastOp {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
                
            case .Variable(let symbol):
                if let validatedSymbol = variableValues[symbol] {
                    return (symbol, remainingOps)
                }
                
            case .UnaryOperation(let symbol, _):
                let continuedDescription = buildDescription(remainingOps)
                if let validString = continuedDescription.opDescription {
                    return ("\(symbol)(\(validString))", continuedDescription.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Description = buildDescription(remainingOps)
                if var validOp1Description = op1Description.opDescription {
                    if remainingOps.count - op1Description.remainingOps.count > 2 {
                        validOp1Description = "(\(validOp1Description))"
                    }
                    let op2Description = buildDescription(op1Description.remainingOps)
                    if let validOp2Description = op2Description.opDescription {
                        var finalDescription = "(\(validOp2Description) \(symbol) \(validOp1Description))"
                        return (finalDescription, op2Description.remainingOps)
                    }
                }
            }
        }
        return ("?", ops)
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
            var remainingOps = ops // this copies ops
            let op = remainingOps.removeLast()
            
            switch op {
                
            // if the Op enum is of type .Operand, we just want to return the operand value and the remaining Ops
            // '(let operand):' allows us to access the value of op.Operand and assign it to operand
            case .Operand(let operand):
                return (operand, remainingOps)
                
            // MARK: finish this case
            case .Variable(let symbol):
                if let value = variableValues[symbol] {
                    return (value, remainingOps)
                }
                
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
        
        if let validResult = result {
            //println("\(opStack) = \(showStack())")
            //println("The brain: \(self)" )
            return validResult
        }
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    // external calls to the brain start here, taking in the operator symbol
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func showStack() -> String? {
        return " ".join(opStack.map{ "\($0)!" })
    }
    
    func clearBrain() {
        opStack = [Op]()
        variableValues["M"] = nil
    }
}