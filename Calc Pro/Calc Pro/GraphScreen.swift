//
//  GraphScreen.swift
//  Calc Pro
//
//  Created by Lucas Popp on 10/12/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class GraphScreen: UIView, Screen {
    
    var cartesianBounds: CartesianBounds = Calculator.cartesianBounds.nonVariableBounds
    var polarBounds: PolarBounds = Calculator.polarBounds.nonVariableBounds
    
    var currentBounds: Bounds {
        get {
            if Calculator.graphType == .polar {
                return polarBounds
            }
            
            return cartesianBounds
        }
    }
    
    var clearingCancelled: Bool = false
    var graphingCancelled: Bool = false
    
    /// Separate layers for each part, so things can be added in the correct order without having to rearrange them each time a new one is added
    let axes: CAShapeLayer = CAShapeLayer()
    let gridlines: CAShapeLayer = CAShapeLayer()
    let lines: CAShapeLayer = CAShapeLayer()
    let labels: CAShapeLayer = CAShapeLayer()
    
    /// Arrays containing the layers
    var axisLayers: [CAShapeLayer] = []
    var gridlineLayers: [CAShapeLayer] = []
    var lineLayers: [[CAShapeLayer]] = []
    var textLayers: [CATextLayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        
        axes.path = CGPath(rect: bounds, transform: nil)
        gridlines.path = CGPath(rect: bounds, transform: nil)
        lines.path = CGPath(rect: bounds, transform: nil)
        labels.path = CGPath(rect: bounds, transform: nil)
        
        layer.addSublayer(gridlines)
        layer.addSublayer(labels)
        layer.addSublayer(lines)
        layer.addSublayer(axes)
        
        clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didBecomeActive() {
        clearingCancelled = true
        graphingCancelled = false
        drawGraph()
    }
    
    func didGoInactive() {
        clearingCancelled = false
        graphingCancelled = true
        clearGraph(inBackground: true)
    }
    
    /// Get the coordinates on the screen, based on the values of the function
    func cartesianCoordinatesOnScreen(x: Double, y: Double) -> CGPoint {
        let xCoord: Double = ((x - cartesianBounds.xMin) / cartesianBounds.xRange) * Double(bounds.size.width)
        let yCoord: Double = Double(bounds.size.height) * (1 - (((y - cartesianBounds.yMin) / cartesianBounds.yRange)))
        
        return CGPoint(x: CGFloat(xCoord), y: CGFloat(yCoord))
    }
    
    /// Get the coordinates at the center of the screen
    func polarCenter() -> CGPoint {
        let xCoord: Double = (polarBounds.xMin / polarBounds.xRange) * Double(bounds.size.width)
        let yCoord: Double = Double(bounds.size.height) * (1 - (polarBounds.yMin / polarBounds.yRange))
        
        return CGPoint(x: CGFloat(xCoord), y: CGFloat(yCoord))
    }
    
    /// Get the coordinates on the screen, based on the values of the function
    func polarCoordinatesOnScreen(θ: Double, r: Double) -> CGPoint {
        let xCoord: Double = (((r * cos(θ)) - polarBounds.xMin) / polarBounds.xRange) * Double(bounds.size.width)
        let yCoord: Double = Double(bounds.size.height) * (1 - ((((r * sin(θ)) - polarBounds.yMin) / polarBounds.yRange)))
        
        return CGPoint(x: CGFloat(xCoord), y: CGFloat(yCoord))
    }
    
    func drawAxes() {
        let xPath: CGMutablePath = CGMutablePath()
        let yPath: CGMutablePath = CGMutablePath()
        
        // Create a line going from (xMin, 0) to (xMax, 0)
        xPath.move(to: cartesianCoordinatesOnScreen(x: currentBounds.xMin, y: 0))
        xPath.addLine(to: cartesianCoordinatesOnScreen(x: currentBounds.xMax, y: 0))
        
        
        // Create a line going from (0, yMin) to (0, yMax)
        yPath.move(to: cartesianCoordinatesOnScreen(x: 0, y: currentBounds.yMin))
        yPath.addLine(to: cartesianCoordinatesOnScreen(x: 0, y: currentBounds.yMax))
        
        let xAxis: CAShapeLayer = CAShapeLayer()
        xAxis.path = xPath
        xAxis.lineWidth = 1
        xAxis.strokeColor = UIColor.black.cgColor
        
        axisLayers.append(xAxis)
        
        let yAxis: CAShapeLayer = CAShapeLayer()
        yAxis.path = yPath
        yAxis.lineWidth = 1
        yAxis.strokeColor = UIColor.black.cgColor
        
        axisLayers.append(yAxis)
        
        axes.addSublayer(xAxis)
        axes.addSublayer(yAxis)
    }
    
    func drawLabels() {
        if Calculator.graphType == .cartesian {
            var gridlineX: Double = cartesianBounds.xStep
            var gridlineY: Double = cartesianBounds.yStep
            
            while gridlineX <= cartesianBounds.xMax {
                var xCoordinate: CGPoint = cartesianCoordinatesOnScreen(x: gridlineX, y: 0)
                
                if !Calculator.graphShowsGridlines {
                    xCoordinate.y += 4
                }
                
                let newLabel: UILabel = UILabel(frame: CGRect(x: xCoordinate.x, y: xCoordinate.y, width: 30, height: 20))
                let newTextLabel: CATextLayer = CATextLayer()
                newTextLabel.contentsScale = UIScreen.main.scale
                newTextLabel.backgroundColor = UIColor.white.cgColor
                
                if round(gridlineX) == gridlineX {
                    newTextLabel.string = "\(Int(gridlineX))"
                    newLabel.text = "\(Int(gridlineX))"
                } else {
                    newTextLabel.string = "\(gridlineX)"
                    newLabel.text = "\(gridlineX)"
                }
                
                newLabel.font = UIFont.systemFont(ofSize: 9)
                
                newTextLabel.font = UIFont.systemFont(ofSize: 9)
                newTextLabel.fontSize = 9
                newTextLabel.foregroundColor = UIColor.black.cgColor
                
                let size: CGSize = newLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                
                newTextLabel.frame = CGRect(x: xCoordinate.x - (size.width / 2), y: xCoordinate.y - 4 - 2 - size.height, width: size.width, height: size.height)
                
                labels.addSublayer(newTextLabel)
                textLayers.append(newTextLabel)
                
                gridlineX += cartesianBounds.xStep
            }
            
            while gridlineY <= cartesianBounds.yMax {
                var yCoordinate: CGPoint = cartesianCoordinatesOnScreen(x: 0, y: gridlineY)
                
                if !Calculator.graphShowsGridlines {
                    yCoordinate.x += 4
                }
                
                let newLabel: UILabel = UILabel(frame: CGRect(x: yCoordinate.x, y: yCoordinate.y, width: 30, height: 20))
                let newTextLabel: CATextLayer = CATextLayer()
                newTextLabel.contentsScale = UIScreen.main.scale
                newTextLabel.backgroundColor = UIColor.white.cgColor
                
                if round(gridlineY) == gridlineY {
                    newTextLabel.string = "\(Int(gridlineY))"
                    newLabel.text = "\(Int(gridlineY))"
                } else {
                    newTextLabel.string = "\(gridlineY)"
                    newLabel.text = "\(gridlineY)"
                }
                
                newLabel.font = UIFont.systemFont(ofSize: 9)
                
                newTextLabel.font = UIFont.systemFont(ofSize: 9)
                newTextLabel.fontSize = 9
                newTextLabel.foregroundColor = UIColor.black.cgColor
                
                let size: CGSize = newLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                
                newTextLabel.frame = CGRect(x: yCoordinate.x - 4 - 2 - size.width, y: yCoordinate.y - (size.height / 2), width: size.width, height: size.height)
                
                labels.addSublayer(newTextLabel)
                textLayers.append(newTextLabel)
                
                gridlineY += cartesianBounds.yStep
            }
            
            gridlineX = -cartesianBounds.xStep
            gridlineY = -cartesianBounds.yStep
            
            while gridlineX >= cartesianBounds.xMin {
                var xCoordinate: CGPoint = cartesianCoordinatesOnScreen(x: gridlineX, y: 0)
                
                if !Calculator.graphShowsGridlines {
                    xCoordinate.y += 4
                }
                
                let newLabel: UILabel = UILabel(frame: CGRect(x: xCoordinate.x, y: xCoordinate.y, width: 30, height: 20))
                let newTextLabel: CATextLayer = CATextLayer()
                newTextLabel.contentsScale = UIScreen.main.scale
                newTextLabel.backgroundColor = UIColor.white.cgColor
                
                if round(gridlineX) == gridlineX {
                    newTextLabel.string = "\(Int(gridlineX))"
                    newLabel.text = "\(Int(gridlineX))"
                } else {
                    newTextLabel.string = "\(gridlineX)"
                    newLabel.text = "\(gridlineX)"
                }
                
                newLabel.font = UIFont.systemFont(ofSize: 9)
                
                newTextLabel.font = UIFont.systemFont(ofSize: 9)
                newTextLabel.fontSize = 9
                newTextLabel.foregroundColor = UIColor.black.cgColor
                
                let size: CGSize = newLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                
                newTextLabel.frame = CGRect(x: xCoordinate.x - (size.width / 2), y: xCoordinate.y + 2, width: size.width, height: size.height)
                
                labels.addSublayer(newTextLabel)
                textLayers.append(newTextLabel)
                
                gridlineX -= cartesianBounds.xStep
            }
            
            while gridlineY >= cartesianBounds.yMin {
                var yCoordinate: CGPoint = cartesianCoordinatesOnScreen(x: 0, y: gridlineY)
                
                if !Calculator.graphShowsGridlines {
                    yCoordinate.x += 4
                }
                
                let newLabel: UILabel = UILabel(frame: CGRect(x: yCoordinate.x, y: yCoordinate.y, width: 30, height: 20))
                let newTextLabel: CATextLayer = CATextLayer()
                newTextLabel.contentsScale = UIScreen.main.scale
                newTextLabel.backgroundColor = UIColor.white.cgColor
                
                if round(gridlineY) == gridlineY {
                    newTextLabel.string = "\(Int(gridlineY))"
                    newLabel.text = "\(Int(gridlineY))"
                } else {
                    newTextLabel.string = "\(gridlineY)"
                    newLabel.text = "\(gridlineY)"
                }
                
                newLabel.font = UIFont.systemFont(ofSize: 9)
                
                newTextLabel.font = UIFont.systemFont(ofSize: 9)
                newTextLabel.fontSize = 9
                newTextLabel.foregroundColor = UIColor.black.cgColor
                
                let size: CGSize = newLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                
                newTextLabel.frame = CGRect(x: yCoordinate.x + 2, y: yCoordinate.y - (size.height / 2), width: size.width, height: size.height)
                
                labels.addSublayer(newTextLabel)
                textLayers.append(newTextLabel)
                
                gridlineY -= cartesianBounds.yStep
            }
        } else if Calculator.graphType == .polar {}
    }
    
    func drawGridlines() {
        let gridlineColor: CGColor = UIColor(white: 0.9, alpha: 1).cgColor
        
        if Calculator.graphType == .cartesian {
            var gridlineX: Double = cartesianBounds.xStep
            var gridlineY: Double = cartesianBounds.yStep
            
            while gridlineX <= cartesianBounds.xMax {
                let gridlinePath: CGMutablePath = CGMutablePath()
                
                var xCoordinate: CGPoint = cartesianCoordinatesOnScreen(x: gridlineX, y: 0)
                
                if Calculator.graphShowsGridlines {
                    gridlinePath.move(to: cartesianCoordinatesOnScreen(x: gridlineX, y: cartesianBounds.yMin))
                    gridlinePath.addLine(to: cartesianCoordinatesOnScreen(x: gridlineX, y: cartesianBounds.yMax))
                } else {
                    xCoordinate.y -= 2
                    
                    gridlinePath.move(to: xCoordinate)
                    
                    xCoordinate.y += 4
                    
                    gridlinePath.addLine(to: xCoordinate)
                }
                
                let gridline: CAShapeLayer = CAShapeLayer()
                gridline.path = gridlinePath
                gridline.lineWidth = 1
                
                if Calculator.graphShowsGridlines {
                    gridline.strokeColor = gridlineColor
                } else {
                    gridline.strokeColor = UIColor.black.cgColor
                }
                
                gridlines.addSublayer(gridline)
                gridlineLayers.append(gridline)
                
                gridlineX += cartesianBounds.xStep
            }
            
            while gridlineY <= cartesianBounds.yMax {
                let gridlinePath: CGMutablePath = CGMutablePath()
                
                var yCoordinate: CGPoint = cartesianCoordinatesOnScreen(x: 0, y: gridlineY)
                
                if Calculator.graphShowsGridlines {
                    gridlinePath.move(to: cartesianCoordinatesOnScreen(x: cartesianBounds.xMin, y: gridlineY))
                    gridlinePath.addLine(to: cartesianCoordinatesOnScreen(x: cartesianBounds.xMax, y: gridlineY))
                } else {
                    yCoordinate.x -= 2
                    
                    gridlinePath.move(to: yCoordinate)
                    
                    yCoordinate.x += 4
                    
                    gridlinePath.addLine(to: yCoordinate)
                }
                
                let gridline: CAShapeLayer = CAShapeLayer()
                gridline.path = gridlinePath
                gridline.lineWidth = 1
                
                if Calculator.graphShowsGridlines {
                    gridline.strokeColor = gridlineColor
                } else {
                    gridline.strokeColor = UIColor.black.cgColor
                }
                
                gridlines.addSublayer(gridline)
                gridlineLayers.append(gridline)
                
                gridlineY += cartesianBounds.yStep
            }
            
            gridlineX = -cartesianBounds.xStep
            gridlineY = -cartesianBounds.yStep
            
            while gridlineX >= cartesianBounds.xMin {
                let gridlinePath: CGMutablePath = CGMutablePath()
                
                var xCoordinate: CGPoint = cartesianCoordinatesOnScreen(x: gridlineX, y: 0)
                
                if Calculator.graphShowsGridlines {
                    gridlinePath.move(to: cartesianCoordinatesOnScreen(x: gridlineX, y: cartesianBounds.yMin))
                    gridlinePath.addLine(to: cartesianCoordinatesOnScreen(x: gridlineX, y: cartesianBounds.yMax))
                } else {
                    xCoordinate.y -= 2
                    
                    gridlinePath.move(to: xCoordinate)
                    
                    xCoordinate.y += 4
                    
                    gridlinePath.addLine(to: xCoordinate)
                }
                
                let gridline: CAShapeLayer = CAShapeLayer()
                gridline.path = gridlinePath
                gridline.lineWidth = 1
                
                if Calculator.graphShowsGridlines {
                    gridline.strokeColor = gridlineColor
                } else {
                    gridline.strokeColor = UIColor.black.cgColor
                }
                
                gridlines.addSublayer(gridline)
                gridlineLayers.append(gridline)
                
                gridlineX -= cartesianBounds.xStep
            }
            
            while gridlineY >= cartesianBounds.yMin {
                let gridlinePath: CGMutablePath = CGMutablePath()
                
                var yCoordinate: CGPoint = cartesianCoordinatesOnScreen(x: 0, y: gridlineY)
                
                if Calculator.graphShowsGridlines {
                    gridlinePath.move(to: cartesianCoordinatesOnScreen(x: cartesianBounds.xMin, y: gridlineY))
                    gridlinePath.addLine(to: cartesianCoordinatesOnScreen(x: cartesianBounds.xMax, y: gridlineY))
                } else {
                    yCoordinate.x -= 2
                    
                    gridlinePath.move(to: yCoordinate)
                    
                    yCoordinate.x += 4
                    
                    gridlinePath.addLine(to: yCoordinate)
                }
                
                let gridline: CAShapeLayer = CAShapeLayer()
                gridline.path = gridlinePath
                gridline.lineWidth = 1
                
                if Calculator.graphShowsGridlines {
                    gridline.strokeColor = gridlineColor
                } else {
                    gridline.strokeColor = UIColor.black.cgColor
                }
                
                gridlines.addSublayer(gridline)
                gridlineLayers.append(gridline)
                
                gridlineY -= cartesianBounds.yStep
            }
        } else if Calculator.graphType == .polar {
            var θStep: Double = polarBounds.θStep
            
            if Calculator.trigUnits == .degrees {
                θStep = θStep * Double.pi / 180
            }
            
            var gridlineθ: Double = θStep
            let radius: Double = sqrt(pow(polarBounds.xRange, 2) + pow(polarBounds.yRange, 2))
            
            while gridlineθ < 2 * Double.pi {
                let gridlinePath: CGMutablePath = CGMutablePath()
                
                gridlinePath.move(to: polarCoordinatesOnScreen(θ: 0, r: 0))
                gridlinePath.addLine(to: polarCoordinatesOnScreen(θ: gridlineθ, r: radius))
                
                let gridline: CAShapeLayer = CAShapeLayer()
                gridline.path = gridlinePath
                gridline.lineWidth = 1
                gridline.strokeColor = gridlineColor
                
                gridlines.addSublayer(gridline)
                gridlineLayers.append(gridline)
                
                gridlineθ += θStep
            }
            
            var gridlineR: Double = polarBounds.rStep
            
            while gridlineR < radius {
                let top: Double = Double(polarCoordinatesOnScreen(θ: Double.pi / 2, r: gridlineR).y)
                let right: Double = Double(polarCoordinatesOnScreen(θ: 0, r: gridlineR).x)
                let bottom: Double = Double(polarCoordinatesOnScreen(θ: Double.pi * 1.5, r: gridlineR).y)
                let left: Double = Double(polarCoordinatesOnScreen(θ: Double.pi, r: gridlineR).x)
                
                let gridline: CAShapeLayer = CAShapeLayer()
                gridline.path = CGPath(ellipseIn: CGRect(x: left, y: top, width: right - left, height: bottom - top), transform: nil)
                gridline.lineWidth = 1
                gridline.fillColor = UIColor.clear.cgColor
                gridline.strokeColor = gridlineColor
                
                gridlines.addSublayer(gridline)
                gridlineLayers.append(gridline)
                
                gridlineR += polarBounds.rStep
            }
        }
    }
    
    func drawLines() {
        let activeFunctions: [Function] = Calculator.activeFunctions
        
        if Calculator.graphType == .cartesian {
            let dScreenX: Double = 0.5
            let dx: Double = dScreenX / Double(bounds.size.width) * Double(cartesianBounds.xRange)
            
            DispatchQueue.global(qos: .utility).async {
                for f: Function in activeFunctions {
                    var lineArray: [CAShapeLayer] = []
                    
                    if f.equation.isEmpty || f.formattedEquation == nil {
                        continue
                    }
                    
                    let formattedEquation: String = f.formattedEquation!
                    
                    var currentScreenX: Double = 0 - dScreenX
                    var currentX: Double = Double(self.cartesianBounds.xMin) - dx
                    var nextScreenX: Double = 0
                    var nextX: Double = Double(self.cartesianBounds.xMin)
                    var currentScreenY: Double = Double.nan
                    var nextScreenY: Double = Double.nan
                    var currentY: Double = Double.nan
                    var nextY: Double = Double.nan
                    
                    let lineColor: CGColor = f.color.cgColor
                    
                    let screenHeight: Double = Double(self.bounds.height)
                    let yMin: Double = self.cartesianBounds.yMin
                    let yMax: Double = self.cartesianBounds.yMax
                    let yRange: Double = self.cartesianBounds.yRange
                    
                    while currentX < self.cartesianBounds.xMax {
                        if self.graphingCancelled {
                            break
                        }
                        
                        currentY = nextY
                        currentScreenY = nextScreenY
                        nextY = Brain.doubleValueOfExpression(formattedInput: formattedEquation, withValue: nextX, forVariable: "x")
                        nextScreenY = Double(screenHeight) * (1 - (((nextY - yMin) / yRange)))
                        
                        if (currentY >= yMin && currentY <= yMax) || (nextY >= yMin && nextY <= yMax) {
                            let linePath: CGMutablePath = CGMutablePath()
                            
                            linePath.move(to: CGPoint(x: currentScreenX, y: currentScreenY))
                            linePath.addLine(to: CGPoint(x: nextScreenX, y: nextScreenY))
                            
                            let lineShape: CAShapeLayer = CAShapeLayer()
                            lineShape.path = linePath
                            lineShape.lineWidth = 1
                            lineShape.strokeColor = lineColor
                            
                            DispatchQueue.main.async {
                                self.lines.addSublayer(lineShape)
                                lineArray.append(lineShape)
                            }
                        }
                        
                        currentX += dx
                        currentScreenX += dScreenX
                        nextX += dx
                        nextScreenX += dScreenX
                    }
                    
                    self.lineLayers.append(lineArray)
                }
            }
        } else if Calculator.graphType == .polar {
            let dθ: Double = 2 * asin(2.squareRoot() / (2 * sqrt(pow(polarBounds.xRange, 2) + pow(polarBounds.yRange, 2))))
            
            let height: Double = Double(bounds.size.height)
            
            DispatchQueue.global(qos: .utility).async {
                for f: Function in activeFunctions {
                    var lineArray: [CAShapeLayer] = []
                    
                    if f.equation.isEmpty || f.formattedEquation == nil {
                        continue
                    }
                    
                    let formattedEquation: String = f.formattedEquation!
                    
                    var θMax: Double = self.polarBounds.θMax
                    
                    var nextθ: Double = self.polarBounds.θMin
                    
                    if Calculator.trigUnits == .degrees {
                        nextθ *= Double.pi / 180
                        θMax *= Double.pi / 180
                    }
                    
                    var currentθ: Double = nextθ - dθ
                    var nextR: Double = Double.nan
                    
                    var currentScreenX: Double = 0
                    var nextScreenX: Double = 0
                    var currentScreenY: Double = Double.nan
                    var nextScreenY: Double = Double.nan
                    
                    let lineColor: CGColor = f.color.cgColor
                    
                    while currentθ < θMax {
                        if self.graphingCancelled {
                            break
                        }
                        
                        nextR = Brain.doubleValueOfExpression(formattedInput: formattedEquation, withValue: nextθ, forVariable: "θ")
                        
                        let nextCoordinates: CGPoint = self.polarCoordinatesOnScreen(θ: nextθ, r: nextR)
                        
                        currentScreenX = nextScreenX
                        currentScreenY = nextScreenY
                        nextScreenX = Double(nextCoordinates.x)
                        nextScreenY = Double(nextCoordinates.y)
                        
                        if (currentScreenY >= 0 && currentScreenY <= height) || (nextScreenY >= 0 && nextScreenY <= height) {
                            let linePath: CGMutablePath = CGMutablePath()
                            
                            linePath.move(to: CGPoint(x: currentScreenX, y: currentScreenY))
                            linePath.addLine(to: CGPoint(x: nextScreenX, y: nextScreenY))
                            
                            let lineShape: CAShapeLayer = CAShapeLayer()
                            lineShape.path = linePath
                            lineShape.lineWidth = 1
                            lineShape.strokeColor = lineColor
                            
                            DispatchQueue.main.async {
                                self.lines.addSublayer(lineShape)
                                lineArray.append(lineShape)
                            }
                        }
                        
                        currentθ += dθ
                        nextθ += dθ
                        
                        if nextθ > θMax {
                            nextθ = θMax
                        }
                    }
                    
                    self.lineLayers.append(lineArray)
                }
            }
        }
    }
    
    /// Toggle the display of a function
    func toggleFunction(index: Int) {
        if lineLayers[index].first != nil {
            if lineLayers[index].first!.isHidden {
                for line: CAShapeLayer in lineLayers[index] {
                    line.isHidden = false
                }
            } else {
                for line: CAShapeLayer in lineLayers[index] {
                    line.isHidden = true
                }
            }
        }
    }
    
    func clearGraph(inBackground: Bool = false) {
        if inBackground {
            DispatchQueue.global(qos: .utility).async {
                while self.axisLayers.count > 0 {
                    self.axisLayers.removeFirst().removeFromSuperlayer()
                }
                
                while self.gridlineLayers.count > 0 {
                    self.gridlineLayers.removeFirst().removeFromSuperlayer()
                }
                
                while self.lineLayers.count > 0 {
                    var arr: [CAShapeLayer] = self.lineLayers.removeFirst()
                    
                    while arr.count > 0 {
                        arr.removeFirst().removeFromSuperlayer()
                    }
                }
                
                while self.textLayers.count > 0 {
                    self.textLayers.removeFirst().removeFromSuperlayer()
                }
            }
        } else {
            while self.axisLayers.count > 0 {
                self.axisLayers.removeFirst().removeFromSuperlayer()
            }
            
            while self.gridlineLayers.count > 0 {
                self.gridlineLayers.removeFirst().removeFromSuperlayer()
            }
            
            while self.lineLayers.count > 0 {
                var arr: [CAShapeLayer] = self.lineLayers.removeFirst()
                
                while arr.count > 0 {
                    arr.removeFirst().removeFromSuperlayer()
                }
            }
            
            while self.textLayers.count > 0 {
                self.textLayers.removeFirst().removeFromSuperlayer()
            }
        }
    }
    
    func drawGraph() {
        clearGraph()
        
        DispatchQueue.global(qos: .utility).async {
            self.cartesianBounds = Calculator.cartesianBounds.nonVariableBounds
            self.polarBounds = Calculator.polarBounds.nonVariableBounds
            
            if !self.currentBounds.areValid {
                return
            }
            
            DispatchQueue.main.async {
                self.drawAxes()
                self.drawGridlines()
                
                if Calculator.graphShowsLabels {
                    self.drawLabels()
                }
                
                self.drawLines()
            }
        }
    }
    
    func updateGraph(oldBounds: CartesianBounds, newBounds: CartesianBounds) {
        cartesianBounds = newBounds
        
        while self.axisLayers.count > 0 {
            self.axisLayers.removeFirst().removeFromSuperlayer()
        }
        
        while self.gridlineLayers.count > 0 {
            self.gridlineLayers.removeFirst().removeFromSuperlayer()
        }
        
        drawAxes()
    }
    
}
