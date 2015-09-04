//
//  GraphView.swift
//  Calculator
//
//  Created by Александр on 20.08.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import UIKit

protocol GraphDataSource: class {
    func funcExecute(x: Double) -> Double?
}

@IBDesignable
class GraphView: UIView {

    weak var dataSource: GraphDataSource?
    
    var pointsPerUnit:Double = 10 { didSet { setNeedsDisplay() } }
    var color = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    var origin: CGPoint? { didSet { setNeedsDisplay() } }
    
    private var graphAxes = AxesDrawer(color: UIColor.blackColor())
    private var xOffset:CGFloat = 0
    
    // MARK: drawing functions
    override func drawRect(rect: CGRect) {
        origin = origin ?? graphCenter
        graphAxes.contentScaleFactor = contentScaleFactor
        graphAxes.drawAxesInRect(self.bounds, origin: self.origin!, pointsPerUnit: CGFloat(pointsPerUnit))
        
        let functionPath = bezierPathForFunctionWithStep(0.1)
        functionPath.stroke()
    }
    
    private func bezierPathForFunctionWithStep(step: Double) -> UIBezierPath {
        let path = UIBezierPath()
        var rightRange = graphCenter.x + xOffset
        var leftRange = -2 * graphCenter.x + rightRange
        var rightBoundary = Double(rightRange) / pointsPerUnit
        let leftBoundary = Double(leftRange) / pointsPerUnit
        
        // передвигаемся в правый край экрана
        if let y = dataSource?.funcExecute(rightBoundary) {
            path.moveToPoint(CGPointMake(bounds.maxX, bounds.midY - CGFloat(y)))
        }
        
        while rightBoundary > leftBoundary {
            if let y = dataSource?.funcExecute(rightBoundary) {
                if isLegitValue(y) {
                    path.addLineToPoint(CGPointMake(origin!.x + CGFloat(rightBoundary * pointsPerUnit), origin!.y - CGFloat(y * pointsPerUnit)))
                } else {
                    // поддержка прерываемых функций
                    path.moveToPoint(CGPointMake(origin!.x + CGFloat(rightBoundary * pointsPerUnit), origin!.y - CGFloat(y * pointsPerUnit)))
                }
            }
            rightBoundary -= step
        }
        
        return path
    }
    
    // MARK: gesture handlers
    func scale(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Changed: fallthrough
        case .Ended:
            pointsPerUnit *= Double(gesture.scale)
            gesture.scale = 1
        default: break
        }
    }
    
    func move(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed: fallthrough
        case .Ended:
            let translation = gesture.translationInView(self)
            xOffset -= translation.x
            origin = CGPointMake(origin!.x + translation.x, origin!.y + translation.y)
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    func moveOrigin(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            let newOrigin = gesture.locationInView(self)
            xOffset = graphCenter.x - newOrigin.x
            origin = newOrigin
        }
    }
    
    // MARK: helper functions
    private var graphCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    private func isLegitValue(inputValue: Double) -> Bool {
        if inputValue.isNormal || inputValue.isZero {
            return true
        } else {
            return false
        }
    }

}
