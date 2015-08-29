//
//  ViewController.swift
//  Calculator
//
//  Created by Александр on 04.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, GraphDataSource {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    var userIsInTheMiddleOfTypingANumber = false
    var numberIsDecimal = false

    var brain = CalculatorBrain()
    
    var displayValue:Double? {
        get {
            if let displayText = display.text {
                return (displayText as NSString).doubleValue
            }
            historyLabel.text = brain.description
            return nil
        }
        set {
            if let legitNewValue = newValue {
                display.text = "\(legitNewValue)"
            } else {
                display.text = " "
            }
            historyLabel.text = brain.description + " = "
            userIsInTheMiddleOfTypingANumber = false

        }
    }

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        
    }
    
    @IBAction func addDecimal() {
        if !numberIsDecimal && userIsInTheMiddleOfTypingANumber {
            numberIsDecimal = true
            display.text = display.text! + "."
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        numberIsDecimal = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.pushOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }
    
    @IBAction func changeSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if startsWith(display.text!, "-") {
                display.text!.removeAtIndex(display.text!.startIndex)
            } else {
                display.text! = "-" + display.text!
            }
        } else {
            operate(sender)
        }
    }
    
    @IBAction func setVariable(sender: UIButton) {
        brain.variableValues["M"] = displayValue
        userIsInTheMiddleOfTypingANumber = false
        let result = brain.evaluate()
        displayValue = result
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        let result = brain.pushOperand(sender.currentTitle!)
        displayValue = result
    }
    
    @IBAction func clearScreen() {
        brain = CalculatorBrain()
        var numberIsDecimal = false
        displayValue = nil
        historyLabel.text = " "
    }
    
    func addHistory(value: String) {
        if historyLabel.text!.isEmpty {
            historyLabel.text! = value
        } else {
            historyLabel.text! += " \(value)"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nvc = segue.destinationViewController as? UINavigationController {
            var destination = nvc.visibleViewController
            if let gvc = destination as? GraphViewController {
                if let identifier = segue.identifier {
                    if identifier == "Print graph" {
                        var labelText = brain.description
                        gvc.title = "y = \(labelText)"
                        gvc.tempDataSource = self
                    }
                }
                
            }
        }
    }
    
    func funcExecute(x: Double) -> Double? {
        brain.variableValues["M"] = x
        let result = brain.evaluate()
        return result
    }
}

