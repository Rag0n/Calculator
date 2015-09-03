//
//  GraphViewController.swift
//  Calculator
//
//  Created by Александр on 20.08.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import UIKit

//protocol 

class GraphViewController: UIViewController, GraphDataSource {

    var program: AnyObject? {
        didSet {
            print("WTF\n\n\n")
            if let brainProgram = program as? [String] {
                brain.program = brainProgram
            }
        }
    }
    private var brain = CalculatorBrain()
    

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
        }
    }

    override func viewDidLoad() {
        self.edgesForExtendedLayout = UIRectEdge.None // do not overlap
        self.graphView.contentMode = UIViewContentMode.Redraw
    }
    
    func funcExecute(x: Double) -> Double? {
        brain.variableValues["M"] = x
        let result = brain.evaluate()
        return result
    }
}
