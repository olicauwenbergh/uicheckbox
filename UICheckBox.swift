//
//  UICheckBox.swift
//  CheckBox
//
//  Created by Olivier Cauwenbergh on 28/09/15.
//  Copyright © 2015 Olivier Cauwenbergh. All rights reserved.
//

import UIKit

protocol UICheckBoxDelegate {
    func didSelectCheckBox(checkBox: UICheckBox, forControlEvents event: UIEvent)
}

@IBDesignable
class UICheckBox: UIControl {

    var delegate: UICheckBoxDelegate?

    // MARK: - Properties -
    // MARK: Unchecked properties
    // Stroke width of the circle and tick
    @IBInspectable var strokeWidth: CGFloat = 1 {
        didSet {
            if strokeWidth != oldValue {
                circleLayer?.borderWidth = strokeWidth
            }
        }
    }

    /// Stroke color of the circle
    @IBInspectable var strokeColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            if strokeColor != oldValue {
                circleLayer?.borderColor = strokeColor.CGColor
            }
        }
    }

    /// Background color of the circle
    @IBInspectable var background: UIColor = UIColor.whiteColor() {
        didSet {
            if background != oldValue {
                circleLayer?.fillColor = background.CGColor
            }
        }
    }

    // MARK: Checked properties
    /// Tick color when checked. Tick is clear when unchecked
    @IBInspectable var tick: UIColor = UIColor.whiteColor() {
        didSet {
            if tick != oldValue {
                tickLayer?.strokeColor = tick.CGColor
            }
        }
    }

    // MARK: State properties
    /// State property to determine whether the box is checked or not
    @IBInspectable var checked: Bool = false {
        didSet {
            if checked != oldValue {
                /// Change the layers when the box get checked and unchecked
                if checked {
                    circleLayer?.fillColor = self.tintColor.CGColor
                    circleLayer?.strokeColor = self.tintColor.CGColor
                    tickLayer?.strokeColor = tick.CGColor
                    tickLayer?.fillColor = UIColor.clearColor().CGColor
                } else {
                    circleLayer?.fillColor = background.CGColor
                    circleLayer?.strokeColor = strokeColor.CGColor
                    tickLayer?.strokeColor = UIColor.clearColor().CGColor
                    tickLayer?.fillColor = UIColor.clearColor().CGColor
                }
            }
        }
    }

    // MARK: Layer properties
    /// Layer to draw the box
    private var circleLayer: CAShapeLayer?

    /// Layer to draw the tick
    private var tickLayer: CAShapeLayer?

    // MARK: - Initialization -
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        addTargetAction()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        addTargetAction()
    }

    // MARK: Target action
    /// Adding target action to the view
    private func addTargetAction() {
        self.addTarget(self, action: Selector("didTappedCheckBox:event:"), forControlEvents: UIControlEvents.TouchUpInside)
    }

    /// Notifies the view has been tapped
    func didTappedCheckBox(sender: UIButton, event: UIEvent) {
        if let delegate = self.delegate {
            delegate.didSelectCheckBox(self, forControlEvents: event)
        }
    }

    // MARK: - Drawing -
    /// Drawing of the two layers, box and tick
    override func drawRect(rect: CGRect) {

        /// Draw circle layer
        /// Determine the biggest possible radius in order to fit the frame
        let biggestRadius = (layer.frame.width < layer.frame.height) ? layer.frame.width : layer.frame.height

        /// Create a circle path for the checkbox button
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: layer.frame.width / 2.0,y: layer.frame.height / 2.0),
            radius: (biggestRadius - (strokeWidth * 2))/2,
            startAngle: 0.0,
            endAngle: CGFloat(M_PI * 2.0),
            clockwise: true)

        /// Initialize the circle layer
        circleLayer = CAShapeLayer()

        /// Add the circle path to the layer
        circleLayer?.path = circlePath.CGPath

        if checked {
            /// Set the circle stroke and fill to the view's tint color
            circleLayer?.fillColor = self.tintColor.CGColor
            circleLayer?.strokeColor = self.tintColor.CGColor
        } else {
            /// Set the circle stroke and fill to the values defined in the properties
            circleLayer?.fillColor = background.CGColor
            circleLayer?.strokeColor = strokeColor.CGColor
        }

        /// Set the stroke width
        circleLayer?.lineWidth = strokeWidth

        /// Draw a complete circle
        circleLayer?.strokeEnd = 1.0

        /// Add the circle layer to the view's layer
        layer.addSublayer(circleLayer!)

        /// Draw tick layer
        /// Determine the size of the side of the biggest square possible inside the circle through Pythagoras Theorem
        let biggestSide = sqrt(pow((biggestRadius), 2) / 2)

        /// Make the side 80% smaller to make a square inside the circle to be used as the bounds of the tick
        let side = (biggestSide / 100 * 80) - (strokeWidth * 2)

        /// Make a square to be used as the bounds of the tick
        let square = CGRectMake((frame.width / 2) - (side / 2), (frame.height / 2) - (side / 2), side, side)

        /// Create a path to form the tick
        let tickPath = UIBezierPath()

        /// Start at the left side of the square, 60% down
        tickPath.moveToPoint(CGPoint(
            x: square.origin.x,
            y: square.origin.y + (square.size.height / 100 * 60)))

        /// Draw line to the bottom side of the square, 40% to the right
        tickPath.addLineToPoint(CGPoint(
            x: square.origin.x + (square.size.width / 100 * 40),
            y: square.origin.y + square.size.height))

        /// Draw a line to the upper right corner of the square
        tickPath.addLineToPoint(CGPoint(
            x: square.origin.x + square.size.width,
            y: square.origin.y))

        /// Initialize the tick layer
        tickLayer = CAShapeLayer()

        /// Add the tick path to the layer
        tickLayer?.path = tickPath.CGPath

        if checked {
            /// Set the tick stroke color and make the fill clear
            tickLayer?.strokeColor = tick.CGColor
            tickLayer?.fillColor = UIColor.clearColor().CGColor
        } else {
            /// Set the tick stroke and fill clear
            tickLayer?.strokeColor = UIColor.clearColor().CGColor
            tickLayer?.fillColor = UIColor.clearColor().CGColor
        }

        /// Set the stroke width
        tickLayer?.lineWidth = strokeWidth

        /// Add the tick layer to the view's layer
        layer.addSublayer(tickLayer!)
    }

}
