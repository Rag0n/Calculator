//
//  GraphView.swift
//  Calculator
//
//  Created by Александр on 20.08.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import UIKit

protocol GraphDataSource {
    func funcExecute(x: Double) -> Double?
}

@IBDesignable
class GraphView: UIView {

    var graphAxes = AxesDrawer()
    var dataSource:GraphDataSource?
    var scale:Double = 50 // Removing an @IBInspectable property from code when it has a custom value set in IB results in runtime error.
    var pointsPerUnit:Double = 10
    
    override func drawRect(rect: CGRect) {
        graphAxes.drawAxesInRect(self.bounds, origin: graphCenter, pointsPerUnit: CGFloat(pointsPerUnit))
        
        let path = UIBezierPath()
        let width = Double(bounds.maxX) / pointsPerUnit
        let range = width / 2
        let step = 0.1
        path.moveToPoint(graphCenter)
        
//        var x = Double(graphCenter.x) / pointsPerUnit // корректно
        var x = range

        
        if let y = dataSource?.funcExecute(x) {
            path.moveToPoint(CGPoint(x: bounds.maxX, y: CGFloat(y)))
        } else
        {
            path.moveToPoint(CGPoint(x: bounds.maxX, y: bounds.midY))
        }
        
        while x > -range {
            if let y = dataSource?.funcExecute(x) {
                // mid - координата, потому что экран растет вниз
                path.addLineToPoint(CGPointMake(bounds.midX + CGFloat(x * pointsPerUnit), bounds.midY - CGFloat(y * pointsPerUnit)))
            }
            x -= step
            
        }
        
//        path.stroke()
//        path.moveToPoint(graphCenter)
//        
//        while x > -range {
//            if let y = dataSource?.funcExecute(x) {
//                path.addLineToPoint(CGPointMake(bounds.midX + CGFloat(x * pointsPerUnit), bounds.midY - CGFloat(y * pointsPerUnit)))
//            }
//            x -= step
//            
//        }
        

        path.stroke()
    }
    
    private var graphCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }

}
