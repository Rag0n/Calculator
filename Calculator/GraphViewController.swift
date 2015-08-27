//
//  GraphViewController.swift
//  Calculator
//
//  Created by Александр on 20.08.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import UIKit

//protocol 

class GraphViewController: UIViewController {

    var tempDataSource: GraphDataSource?
    

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = tempDataSource
        }
    }

    override func viewDidLoad() {
        self.edgesForExtendedLayout = UIRectEdge.None // do not overlap
        self.graphView.contentMode = UIViewContentMode.Redraw
    }
    

    
}
