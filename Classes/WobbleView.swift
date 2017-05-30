//
//  WoblingView.swift
//  Example
//
//  Created by Wojciech Lukaszuk on 07/04/15.
//  Copyright (c) 2015 inFullMobile. All rights reserved.
//

import UIKit
import QuartzCore

open class WobbleView: UIView {
    
    /*
    The frequency of oscillation for the wobble behavior.
    */
    @IBInspectable open var frequency: CGFloat = 3
    
    /*
    The amount of damping to apply to the wobble behavior.
    */
    @IBInspectable open var damping: CGFloat = 0.3
    
    /*
    A bitmask value that identifies the edges that you want to wobble.
    You can use this parameter to wobble only a subset of the edges of the rectangle.
    */
    @IBInspectable open var edges: ViewEdge = .Right
    
    // MARK: init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    fileprivate func setUp() {
        
        layer.masksToBounds = false
        layer.addSublayer(maskLayer)
        (layer as! WobbleLayer).wobbleDelegate = self
        
        setUpVertices()
        setUpMidpoints()
        setUpCenters()
        setUpBehaviours()
        setUpDisplayLink()
    }
    
    open func reset() {
        
        setUpMidpoints()
        setUpCenters()
        setUpBehaviours()
        
        if vertexViews[0].layer.presentation() != nil {
            
            let bezierPath = UIBezierPath()
            bezierPath.move(to: vertexViews[0].layer.presentation()!.frame.origin - layer.presentation()!.frame.origin)
            bezierPath.addLine(to: vertexViews[1].layer.presentation()!.frame.origin - layer.presentation()!.frame.origin)
            bezierPath.addLine(to: vertexViews[2].layer.presentation()!.frame.origin - layer.presentation()!.frame.origin)
            bezierPath.addLine(to: vertexViews[3].layer.presentation()!.frame.origin - layer.presentation()!.frame.origin)
            bezierPath.close()
            
            maskLayer.path = bezierPath.cgPath
            (layer as! CAShapeLayer).path = bezierPath.cgPath
            layer.mask = maskLayer
        }
    }
    
    fileprivate func setUpVertices() {
        
        vertexViews = []
        
        let verticesOrigins = [CGPoint(x: frame.origin.x, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height),
            CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)]
        
        createAdditionalViews(&vertexViews, origins: verticesOrigins)
    }
    
    fileprivate func setUpMidpoints() {
        
        midpointViews = []
        
        let midpointsOrigins = [CGPoint(x: frame.origin.x + frame.width/2, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height/2),
            CGPoint(x: frame.origin.x + frame.width/2, y: frame.origin.y + frame.height),
            CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height/2)]
        
        createAdditionalViews(&midpointViews, origins: midpointsOrigins)
    }
    
    fileprivate func setUpCenters() {
        
        centerViews = []
        
        let radius = min(frame.size.width/2, frame.size.height/2)
        
        let centersOrigins = [CGPoint(x: frame.origin.x + frame.width/2, y: frame.origin.y + radius),
            CGPoint(x: (frame.origin.x + frame.width) - radius, y: frame.origin.y + frame.height/2),
            CGPoint(x: frame.origin.x + frame.width/2, y: (frame.origin.y + frame.height) - radius),
            CGPoint(x: frame.origin.x + radius, y: frame.origin.y + frame.height/2)]
        
        createAdditionalViews(&centerViews, origins: centersOrigins)
    }
    
    fileprivate func setUpBehaviours() {
        
        animator = UIDynamicAnimator(referenceView: self)
        animator!.delegate = self
        verticesAttachments = []
        centersAttachments = []
        
        for (i, midPointView) in midpointViews.enumerated() {
            
            let formerVertexIndex = i
            let latterVertexIndex = (i + 1) % vertexViews.count
            
            createAttachmentBehaviour(&verticesAttachments, view: midPointView, vertexIndex: formerVertexIndex)
            createAttachmentBehaviour(&verticesAttachments, view: midPointView, vertexIndex: latterVertexIndex)
            createAttachmentBehaviour(&centersAttachments, view: midPointView, vertexIndex: formerVertexIndex)
        }
    }
    
    fileprivate func setUpDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: "displayLinkUpdate:")
        displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        displayLink!.isPaused = true
    }
    
    // MARK: CADisplayLink selector
    internal func displayLinkUpdate(_ sender: CADisplayLink) {
        
        for behavour in centersAttachments {
            behavour.anchorPoint = centerViews[behavour.vertexIndex!].layer.presentation()!.frame.origin
        }
        
        for behavour in verticesAttachments {
            behavour.anchorPoint = vertexViews[behavour.vertexIndex!].layer.presentation()!.frame.origin
        }
        
        var bezierPath = UIBezierPath()
        bezierPath.move(to: vertexViews[0].layer.presentation()!.frame.origin - layer.presentation()!.frame.origin)
        addEdge(&bezierPath, formerVertex: 0, latterVertex: 1, curved: edges.intersection(.Top))
        addEdge(&bezierPath, formerVertex: 1, latterVertex: 2, curved: edges.intersection(.Right))
        addEdge(&bezierPath, formerVertex: 2, latterVertex: 3, curved: edges.intersection(.Bottom))
        addEdge(&bezierPath, formerVertex: 3, latterVertex: 0, curved: edges.intersection(.Left))
        bezierPath.close()
        
        maskLayer.path = bezierPath.cgPath
        (layer as! CAShapeLayer).path = bezierPath.cgPath
        layer.mask = maskLayer
    }
    
    // MARK: overrides
    override open var backgroundColor: UIColor? {
        didSet {
            (layer as! CAShapeLayer).fillColor = backgroundColor!.cgColor
        }
    }
    
    override open class var layerClass : AnyClass {
        return WobbleLayer.self
    }
    
    // MARK: helpers
    fileprivate func createAdditionalViews(_ views: inout [UIView], origins: [CGPoint]) {
        
        for origin in origins {
            
            let view = UIView(frame: CGRect(origin: origin, size: CGSize(width: 1, height: 1)))
            view.backgroundColor = UIColor.clear
            addSubview(view)
            
            views.append(view)
        }
    }
    
    fileprivate func createAttachmentBehaviour(_ behaviours: inout [VertexAttachmentBehaviour], view: UIView, vertexIndex: Int) {
        
        let attachmentBehaviour = VertexAttachmentBehaviour(item: view, attachedToAnchor: vertexViews[vertexIndex].frame.origin)
        attachmentBehaviour.damping = damping
        attachmentBehaviour.frequency = frequency
        attachmentBehaviour.vertexIndex = vertexIndex
        animator!.addBehavior(attachmentBehaviour)
        
        behaviours.append(attachmentBehaviour)
    }
    
    fileprivate func addEdge(_ bezierPath: inout UIBezierPath, formerVertex: Int, latterVertex: Int, curved: ViewEdge) {
        
        if (curved).boolValue {
            
            let controlPoint = (vertexViews[formerVertex].layer.presentation()!.frame.origin - (midpointViews[formerVertex].layer.presentation()!.frame.origin - vertexViews[latterVertex].layer.presentation()!.frame.origin)) - layer.presentation()!.frame.origin
            
            bezierPath.addQuadCurve(to: vertexViews[latterVertex].layer.presentation()!.frame.origin - layer.presentation()!.frame.origin,
                controlPoint: controlPoint)
            
            return;
        }
        
        bezierPath.addLine(to: vertexViews[latterVertex].layer.presentation()!.frame.origin - layer.presentation()!.frame.origin)
    }
    
    // MARK: private variables
    
    // views considered as rectangle's vertices
    fileprivate var vertexViews:[UIView] = []
    
    // views considered as midpoints of rectangle's edges
    fileprivate var midpointViews:[UIView] = []
    
    // views considered as centers for rectangle's edges
    fileprivate var centerViews: [UIView] = []
    
    fileprivate var animator: UIDynamicAnimator?
    fileprivate var displayLink: CADisplayLink?
    fileprivate var maskLayer: CAShapeLayer = CAShapeLayer()
    
    // midpoints' attachment behaviours to vertices views
    fileprivate var verticesAttachments:[VertexAttachmentBehaviour] = []
    
    // midpoints' attachment behaviours to center view
    fileprivate var centersAttachments:[VertexAttachmentBehaviour] = []
}

// MARK: UIDynamicAnimatorDelegate
extension WobbleView: UIDynamicAnimatorDelegate {
    
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        displayLink!.isPaused = true
    }
}

// MARK: WobbleDelegate
extension WobbleView: WobbleDelegate {
    
    func positionChanged() {
        
        displayLink!.isPaused = false
        
        let verticesOrigins = [CGPoint(x: frame.origin.x, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height),
            CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)]
        
        for (i, vertexView)  in vertexViews.enumerated()    {
            vertexView.frame.origin = verticesOrigins[i]
        }
        
        let radius = min(frame.size.width/2, frame.size.height/2)
        
        let centersOrigins = [CGPoint(x: frame.origin.x + frame.width/2, y: frame.origin.y + radius),
            CGPoint(x: (frame.origin.x + frame.width) - radius, y: frame.origin.y + frame.height/2),
            CGPoint(x: frame.origin.x + frame.width/2, y: (frame.origin.y + frame.height) - radius),
            CGPoint(x: frame.origin.x + radius, y: frame.origin.y + frame.height/2)]
        
        for (i, centerView)  in centerViews.enumerated()    {
            centerView.frame.origin = centersOrigins[i]
        }
    }
}

// MARK: helper classes

private func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

private class VertexAttachmentBehaviour: UIAttachmentBehavior {
    var vertexIndex: Int?
}

private protocol WobbleDelegate {
    func positionChanged()
}

private class WobbleLayer: CAShapeLayer {
    
    var wobbleDelegate: WobbleDelegate?
    
    @objc override var position: CGPoint {
        didSet {
            wobbleDelegate?.positionChanged()
        }
    }
}

public struct ViewEdge : OptionSet {
    
    fileprivate var value: UInt = 0
    
    public init(nilLiteral: ()) {}
    
    public init(rawValue value: UInt) {
        self.value = value
    }
    
    public var boolValue: Bool {
        return value != 0
    }
    
    public var rawValue: UInt {
        return value
    }
    
    static public var allZeros: ViewEdge {
        return self.init(rawValue: 0)
    }
    
    static public var None: ViewEdge {
        return self.init(rawValue: 0b0000)
    }
    
    static public var Left: ViewEdge{
        return self.init(rawValue: 0b0001)
    }
    
    static public var Top: ViewEdge {
        return self.init(rawValue: 0b0010)
    }
    
    static public var Right: ViewEdge {
        return self.init(rawValue: 0b0100)
    }
    
    static public var Bottom: ViewEdge {
        return self.init(rawValue: 0b1000)
    }
    
    static public var All: ViewEdge {
        return self.init(rawValue: 0b1111)
    }
}
