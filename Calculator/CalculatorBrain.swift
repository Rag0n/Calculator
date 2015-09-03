//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Александр on 10.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case ConstantOperation(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let varName):
                    return varName
                case .ConstantOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    var description: String { // get-only
        let (result, remainingOps) = description(opStack)
        if let legitResult = result {
            println("\(legitResult)")
            return legitResult
        }
        return " "
    }
 
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    var variableValues = [String:Double]()
    var program: AnyObject { // PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opValues = newValue as? [String] {
                var newOpStack = [Op]()
                for opValue in opValues {
                    if let operation = knownOps[opValue] {
                        newOpStack.append(operation)
                    } else {
                        let operand = (opValue as NSString).doubleValue
                        newOpStack.append(.Operand(operand))
                    }
                }
            }
        }
    }
    
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
//        knownOps["×"] = Op.BinaryOperation("×", *)
//        knownOps["÷"] = Op.BinaryOperation("÷", *)
//        knownOps["+"] = Op.BinaryOperation("+", *)
//        knownOps["−"] = Op.BinaryOperation("−", *)

        learnOp(Op.BinaryOperation("×", { $1 * $0 }))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }))
        learnOp(Op.BinaryOperation("+", { $1 + $0 }))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }))
        
        learnOp(Op.UnaryOperation("√", { sqrt($0) }))
        learnOp(Op.UnaryOperation("sin", { sin($0) }))
        learnOp(Op.UnaryOperation("cos", { cos($0) }))
        learnOp(Op.UnaryOperation("±", { -$0 }))
        
        learnOp(Op.ConstantOperation("π", M_PI))
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func pushOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    

    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Variable(let varName):
                return ("\(varName)", remainingOps)
            case .ConstantOperation(let operationName, _):
                return ("\(operationName)", remainingOps)
            case .UnaryOperation(let operationName, _):
                let evaluation = description(remainingOps)
                if let result = evaluation.result {
                    return ("\(operationName)(\(result))", evaluation.remainingOps)
                }
            case .BinaryOperation(let operationName, _):
                let firstEvaluation = description(remainingOps)
                if let firstResult = firstEvaluation.result {
                    let secondEvaluation = description(firstEvaluation.remainingOps)
                    if let secondResult = secondEvaluation.result {
                        return ("(\(secondResult) \(operationName) \(firstResult))", secondEvaluation.remainingOps)
                    }
                }
                
            }
            
        }
        
        return ("?", ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainingOps) = evaluate(opStack)
        println("Stack is \(opStack), result = \(result), and remaining stack is \(remainingOps)")
        return result
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let varName):
                if let varValue = variableValues[varName] {
                    return (varValue, remainingOps)
                }
                return (nil, remainingOps)
            case .ConstantOperation(_, let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let firstOperand = evaluate(remainingOps)
                if let result = firstOperand.result {
                    return (operation(result), firstOperand.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let firstOperand = evaluate(remainingOps)
                if let firstResult = firstOperand.result {
                    let SecondOperand = evaluate(firstOperand.remainingOps)
                    if let SecondResult = SecondOperand.result {
                        return (operation(firstResult, SecondResult), SecondOperand.remainingOps)
                    }
                }
            }

        }
        
        return (nil, ops)
    }
}