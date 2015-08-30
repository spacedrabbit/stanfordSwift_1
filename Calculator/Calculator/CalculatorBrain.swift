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
    enum Op{
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    
    var opStack = [Op]()
    var knownOps = [String: Op]()
    
    init(){
        // these dictionary values match the operations defined in the first and second lecture
        knownOps["×"] = Op.BinaryOperation("×", { $0 * $1 })
        knownOps["÷"] = Op.BinaryOperation("÷", { $1 / $0 })
        knownOps["+"] = Op.BinaryOperation("+", { $0 + $1 })
        knownOps["−"] = Op.BinaryOperation("−", { $1 - $0 })
        knownOps["√"] = Op.UnaryOperation("√", { sqrt($0) })
    }
    
    func pushOperand(operand: Double){
        // this statement effectively says, to add type Op.Operand with value of operand to the opStack
        opStack.append(Op.Operand(operand))
    }
    
    func performOperation(symbol: String){
        
    }
}