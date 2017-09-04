//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by KimYusung on 9/3/17.
//  Copyright © 2017 yusungkim. All rights reserved.
//

import Foundation

func multiply(op1: Double, op2: Double) -> Double {
    return op1 * op2
}
// struct is... different from class
// 1. No Inheritance
// 2. Not live in heap, so copy values
// 3. No Initializer is need.
// 4. 'mutating' is need when you change var, because struct should be written before deliver it's value by copying.
struct CalculatorBrain {
    private var accumulator: Double?
    
    private enum Operation {
        case constance(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constance(Double.pi),
        "e" : Operation.constance(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "±" : Operation.unaryOperation({-$0}),
        "×" : Operation.binaryOperation(multiply),
        "÷" : Operation.binaryOperation({$0 / $1}),
        "+" : Operation.binaryOperation({$0 + $1}),
        "−" : Operation.binaryOperation({$0 - $1}),
        "=" : Operation.equals
    ]
    
    mutating func addUnaryOperation(named symbol: String, _ operation: @escaping (Double) -> Double) {
        operations[symbol] = Operation.unaryOperation(operation)
    }
    
    mutating func perfromOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constance(let associatedConstanceValue):
                accumulator = associatedConstanceValue
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                perfromPendingBinaryOperation()
            }
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    private mutating func perfromPendingBinaryOperation() {
        if pendingBinaryOperation != nil, accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperation(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return  accumulator
        }
    }
}
