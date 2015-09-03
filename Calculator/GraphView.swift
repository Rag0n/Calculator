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
    
    private struct Constants {
        static let moveGraphGestureScale: CGFloat = 4
    }
    
    private var xOffset:CGFloat = 0
    
    override func drawRect(rect: CGRect) {
        origin = origin ?? graphCenter
        graphAxes.contentScaleFactor = contentScaleFactor
        graphAxes.drawAxesInRect(self.bounds, origin: self.origin!, pointsPerUnit: CGFloat(pointsPerUnit))
        
        let functionPath = bezierPathForFunctionWithPrecise(0.1)
        functionPath.stroke()
    }
    
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
            var translation = gesture.translationInView(self)
            xOffset -= translation.x
            origin = CGPointMake(origin!.x + translation.x, origin!.y + translation.y)
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    private func bezierPathForFunctionWithPrecise(precise: Double) -> UIBezierPath {
        let path = UIBezierPath()
        
        var range: CGFloat
        range = graphCenter.x + xOffset
        
        var x = Double(range) / pointsPerUnit
        
        // передвигаемся на range вправо
        if let y = dataSource?.funcExecute(x) {
            path.moveToPoint(CGPointMake(bounds.maxX, bounds.midY - CGFloat(y)))
        }
        
        while x > 0 {
            if let y = dataSource?.funcExecute(x) {
                if isLegitValue(y) {
                    path.addLineToPoint(CGPointMake(origin!.x + CGFloat(x * pointsPerUnit), origin!.y - CGFloat(y * pointsPerUnit)))
                } else {
                     path.moveToPoint(CGPointMake(origin!.x + CGFloat(x * pointsPerUnit), origin!.y - CGFloat(y * pointsPerUnit)))
                }
            }
            x -= precise
        }
        
//        let width = Double(bounds.maxX) / pointsPerUnit // 32
//        let range = width / 2 // 16
        
//        let range = Double(origin!.x) / pointsPerUnit
//        path.moveToPoint(origin!)
//        var x = range
//        
//        // рисуем график справа-налево
//        if let y = dataSource?.funcExecute(x) {
//            path.moveToPoint(CGPoint(x: CGFloat(x * pointsPerUnit * 2), y: bounds.midY))
//        } else {
//            path.moveToPoint(CGPoint(x: bounds.maxX, y: bounds.midY))
//        }
//        
//        var steps = Double(bounds.maxX) / precise
//        steps = Double(bounds.maxX) / 2
//        while steps > 0 {
//            if let y = dataSource?.funcExecute(x) {
//                // mid - координата, потому что экран растет вниз
//                path.addLineToPoint(CGPointMake(bounds.midX + CGFloat(x * pointsPerUnit), bounds.midY - CGFloat(y * pointsPerUnit)))
//            }
//            
//            x -= precise
//            steps--
//        }
        
        
//        // рисуем график справа-налево
//        if let y = dataSource?.funcExecute(x) {
//            path.moveToPoint(CGPoint(x: bounds.maxX, y: CGFloat(y)))
//        } else {
//            path.moveToPoint(CGPoint(x: bounds.maxX, y: bounds.midY))
//        }
//        
//        while x > -range {
//            if let y = dataSource?.funcExecute(x) {
//                // mid - координата, потому что экран растет вниз
//                path.addLineToPoint(CGPointMake(bounds.midX + CGFloat(x * pointsPerUnit), bounds.midY - CGFloat(y * pointsPerUnit)))
//            }
//            x -= precise
//            
//        }
        return path
    }
    
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
