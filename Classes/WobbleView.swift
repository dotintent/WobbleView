//
//  WoblingView.swift
//  Example
//
//  Created by Wojciech Lukaszuk on 07/04/15.
//  Copyright (c) 2015 inFullMobile. All rights reserved.
//

import UIKit
import QuartzCore

public class WobbleView: UIView, WobbleDelegate {
    
    /*
    The frequency of oscillation for the wobble behavior.
    */
    @IBInspectable public var frequency: CGFloat = 3
    
    /*
    The amount of damping to apply to the wobble behavior.
    */
    @IBInspectable public var damping: CGFloat = 0.3
    
    /*
    A bitmask value that identifies the edges that you want to wobble.
    You can use this parameter to wobble only a subset of the edges of the rectangle.
    */
    @IBInspectable public var edges: ViewEdge = ViewEdge.All
    
    // MARK: init
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    private func setUp() {
        
        layer.masksToBounds = false
        layer.addSublayer(maskLayer)
        (layer as! WobbleLayer).wobbleDelegate = self
        
        setUpVertices()
        setUpMidpoints()
        setUpCenter()
        setUpBehaviours()
        setUpDisplayLink()
    }
    
    private func setUpVertices() {
        
        vertexViews = []
        
        let verticesOrigins = [CGPoint(x: frame.origin.x, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height),
            CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)]
        
        createAdditionalViews(&vertexViews, origins: verticesOrigins)
    }
    
    private func setUpMidpoints() {
        
        midpointViews = []
        
        let midpointsOrigins = [CGPoint(x: frame.origin.x + frame.width/2, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height/2),
            CGPoint(x: frame.origin.x + frame.width/2, y: frame.origin.y + frame.height),
            CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height/2)]
        
        createAdditionalViews(&midpointViews, origins: midpointsOrigins)
    }
    
    private func setUpCenter() {
        
        var centerOrigin = CGPoint(x: frame.origin.x + frame.width/2, y: frame.origin.y + frame.height/2)
        
        centerView = UIView(frame: CGRect(origin: centerOrigin, size: CGSizeMake(1, 1)))
        centerView.backgroundColor = UIColor.clearColor()
        addSubview(centerView)
    }
    
    private func setUpBehaviours() {
        
        animator = UIDynamicAnimator(referenceView: self)
        animator!.delegate = self
        verticesAttachments = []
        centerAttachments = []
        
        for (i, midPointView) in enumerate(midpointViews) {
            
            let formerVertexIndex = i
            let latterVertexIndex = (i + 1) % vertexViews.count
            
            createVertexAttachment(midPointView, vertexIndex: formerVertexIndex)
            createVertexAttachment(midPointView, vertexIndex: latterVertexIndex)
            createCenterAttachment(midPointView)
        }
    }
    
    private func setUpDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: "displayLinkUpdate:")
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink!.paused = true
    }
    
    // MARK: CADisplayLink selector
    internal func displayLinkUpdate(sender: CADisplayLink) {
        
        for behavour in centerAttachments {
            behavour.anchorPoint = centerView.layer.presentationLayer().frame.origin
        }
        
        for behavour in verticesAttachments {
            behavour.anchorPoint = vertexViews[behavour.vertexIndex!].layer.presentationLayer().frame.origin
        }
        
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(vertexViews[0].layer.presentationLayer().frame.origin - layer.presentationLayer().frame.origin)
        addEdge(&bezierPath, formerVertex: 0, latterVertex: 1, curved: edges & ViewEdge.Top)
        addEdge(&bezierPath, formerVertex: 1, latterVertex: 2, curved: edges & ViewEdge.Right)
        addEdge(&bezierPath, formerVertex: 2, latterVertex: 3, curved: edges & ViewEdge.Bottom)
        addEdge(&bezierPath, formerVertex: 3, latterVertex: 0, curved: edges & ViewEdge.Left)
        bezierPath.closePath()
        
        maskLayer.path = bezierPath.CGPath
        (layer as! CAShapeLayer).path = bezierPath.CGPath
        layer.mask = maskLayer
    }
    
    // MARK: overrides
    override public var backgroundColor: UIColor? {
        didSet {
            (layer as! CAShapeLayer).fillColor = backgroundColor!.CGColor
        }
    }
    
    override public class func layerClass() -> AnyClass {
        return WobbleLayer.self
    }
    
    // MARK: helpers
    private func createAdditionalViews(inout views: [UIView], origins: [CGPoint]) {
        
        for origin in origins {
            
            var view = UIView(frame: CGRect(origin: origin, size: CGSize(width: 1, height: 1)))
            view.backgroundColor = UIColor.clearColor()
            addSubview(view)
            
            views.append(view)
        }
    }
    
    private func createVertexAttachment(view: UIView, vertexIndex: Int) {
        
        var formerVertexAttachment = MidPointAttachmentBehaviour(item: view, attachedToAnchor: vertexViews[vertexIndex].frame.origin)
        formerVertexAttachment.damping = damping
        formerVertexAttachment.frequency = frequency
        formerVertexAttachment.vertexIndex = vertexIndex
        animator!.addBehavior(formerVertexAttachment)
        
        verticesAttachments.append(formerVertexAttachment)
    }
    
    private func createCenterAttachment(view: UIView) {
        
        var centerAttachment = UIAttachmentBehavior(item: view, attachedToAnchor: centerView.frame.origin)
        centerAttachment.damping = damping
        centerAttachment.frequency = frequency
        animator!.addBehavior(centerAttachment)
        
        centerAttachments.append(centerAttachment)
    }
    
    private func addEdge(inout bezierPath: UIBezierPath, formerVertex: Int, latterVertex: Int, curved: ViewEdge) {
        
        if (curved) {
            
            var controlPoint = (vertexViews[formerVertex].layer.presentationLayer().frame.origin - (midpointViews[formerVertex].layer.presentationLayer().frame.origin - vertexViews[latterVertex].layer.presentationLayer().frame.origin)) - layer.presentationLayer().frame.origin
            
            bezierPath.addQuadCurveToPoint(vertexViews[latterVertex].layer.presentationLayer().frame.origin - layer.presentationLayer().frame.origin,
                controlPoint: controlPoint)
            
            return;
        }
        
        bezierPath.addLineToPoint(vertexViews[latterVertex].layer.presentationLayer().frame.origin - layer.presentationLayer().frame.origin)
    }
    
    // MARK: private variables
    
    // views considered as rectangle's vertices
    private var vertexViews:[UIView] = []
    
    // views considered as midpoints of rectangle's sides
    private var midpointViews:[UIView] = []
    
    // view considered as center of rectangle
    private var centerView: UIView = UIView()
    
    private var animator: UIDynamicAnimator?
    private var displayLink: CADisplayLink?
    private var maskLayer: CAShapeLayer = CAShapeLayer()
    
    // midpoints' attachment behaviours to vertices views
    private var verticesAttachments:[MidPointAttachmentBehaviour] = []
    
    // midpoints' attachment behaviours to center view
    private var centerAttachments:[UIAttachmentBehavior] = []
}

// MARK: UIDynamicAnimatorDelegate
 extension WobbleView: UIDynamicAnimatorDelegate {
    
    public func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        displayLink!.paused = true
    }
}

// MARK: WobbleDelegate
extension WobbleView: WobbleDelegate {
    
    func positionChanged() {
        
        displayLink!.paused = false
        
        let verticesOrigins = [CGPoint(x: frame.origin.x, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y),
            CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height),
            CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)]
        
        for (i, vertexView)  in enumerate(vertexViews)    {
            vertexView.frame.origin = verticesOrigins[i]
        }
        
        centerView.frame.origin = CGPoint(x: frame.origin.x + frame.width/2, y: frame.origin.y + frame.height/2)
    }
}

// MARK: helper classes

infix  operator - { associativity left precedence 160 }

private func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

private class MidPointAttachmentBehaviour: UIAttachmentBehavior {
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

public struct ViewEdge : RawOptionSetType, BooleanType {
    
    private var value: UInt = 0
    
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
        return self(rawValue: 0)
    }
    
    static public var None: ViewEdge {
        return self(rawValue: 0b0000)
    }
    
    static public var Left: ViewEdge{
        return self(rawValue: 0b0001)
    }
    
    static public var Top: ViewEdge {
        return self(rawValue: 0b0010)
    }
    
    static public var Right: ViewEdge {
        return self(rawValue: 0b0100)
    }
    
    static public var Bottom: ViewEdge {
        return self(rawValue: 0b1000)
    }
    
    static public var All: ViewEdge {
        return self(rawValue: 0b1111)
    }
}