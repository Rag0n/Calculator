//
//  GraphViewController.swift
//  Calculator
//
//  Created by Александр on 20.08.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController, GraphDataSource {
    // model
    var program: AnyObject? {
        didSet {
            if let brainProgram = program as? [String] {
                brain.program = brainProgram
            }
        }
    }
    
    private var brain = CalculatorBrain()
    

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "move:"))
            let doubleTapGesture = UITapGestureRecognizer(target: graphView, action: "moveOrigin:")
            doubleTapGesture.numberOfTapsRequired = 2
            doubleTapGesture.numberOfTouchesRequired = 1
            graphView.addGestureRecognizer(doubleTapGesture)
        }
    }

    override func viewDidLoad() {
        self.edgesForExtendedLayout = UIRectEdge.None // do not overlap
        self.graphView.contentMode = UIViewContentMode.Redraw // rotations redraw
    }
    
    func funcExecute(x: Double) -> Double? {
        brain.variableValues["M"] = x
        let result = brain.evaluate()
        return result
    }
}
