//
//  CalculatorViewController.swift
//  Calc Pro
//
//  Created by Lucas Popp on 4/20/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, ButtonPadDelegate {
    
    var currentScreen: Screen? {
        willSet {
            if currentScreen != nil && currentScreen is UIView {
                currentScreen!.didGoInactive()
                (currentScreen as! UIView).removeFromSuperview()
                
                if currentScreen is GraphScreen {
                    showPad(pad: mainPad, top: view.frame.size.height - mainPad.frame.size.height, animated: true, completion: nil)
                    hidePad(pad: graphPadContainer, animated: true, completion: nil)
                }
            }
        }
        
        didSet {
            if currentScreen != nil && currentScreen is UIView {
                if currentScreen is GraphScreen {
                    lid.isHidden = false
                    UIApplication.shared.statusBarStyle = .lightContent
                    (currentScreen as! UIView).frame = CGRect(x: 0, y: 20, width: view.bounds.size.width, height: view.bounds.size.width)
                } else {
                    lid.isHidden = true
                    UIApplication.shared.statusBarStyle = .default
                    (currentScreen as! UIView).frame = CGRect(x: 0, y: 20, width: view.bounds.size.width, height: mainPad.frame.origin.y - 20)
                }
                
                view.addSubview(currentScreen as! UIView)
                view.bringSubview(toFront: graphPadContainer)
                view.bringSubview(toFront: mainPad)
                currentScreen!.didBecomeActive()
                
                if currentScreen is GraphScreen {
                    functionList.update()
                    
                    hidePad(pad: mainPad, animated: true, completion: nil)
                    showPad(pad: graphPadContainer, top: view.frame.size.height - graphPadContainer.frame.size.height, animated: true, completion: nil)
                } else {
                    mainPad.enableAllButtons()
                    
                    if currentScreen! is ButtonPadDelegate {
                        (currentScreen as! ButtonPadDelegate).disableButtons(pad: mainPad)
                    }
                }
                
                view.bringSubview(toFront: lid)
            }
        }
    }
    
    let lid: UIView = UIView(frame: CGRect.zero)
    
    let mainScreen: MainScreen = Calculator.mainScreen
    let functionScreen: FunctionScreen = Calculator.functionScreen
    let boundsScreen: BoundsScreen = Calculator.boundsScreen
    let graphScreen: GraphScreen = Calculator.graphScreen
    let tableScreen: TableScreen = Calculator.tableScreen
    
    let mainPad: MainPad = Calculator.mainPad
    let graphPad: GraphPad = Calculator.graphPad
    
    let functionList: FunctionList = FunctionList(frame: CGRect.zero)
    
    let graphPadContainer: UIView = UIView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lid.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 20)
        lid.backgroundColor = Button.darkBackgroundColor
        lid.isHidden = true
        view.addSubview(lid)
        
        mainPad.frame = CGRect(x: 0, y: 20 + ((view.frame.size.height - 20) / 3), width: view.frame.size.width, height: (2/3) * (view.frame.size.height - 20))
        mainPad.delegate = self
        
        graphPadContainer.frame = CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: view.bounds.size.height - 20 - view.bounds.size.width)
        
        graphPad.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: graphPad.defaultHeight)
        graphPad.delegate = self
        
        functionList.frame = CGRect(x: 0, y: graphPad.bounds.size.height, width: view.bounds.size.width, height: graphPadContainer.bounds.size.height - graphPad.bounds.size.height)
        
        view.addSubview(mainPad)
        view.addSubview(graphPadContainer)
        graphPadContainer.addSubview(graphPad)
        graphPadContainer.addSubview(functionList)
        
        mainScreen.frame = CGRect(x: 0, y: 20, width: view.bounds.size.width, height: mainPad.frame.origin.y - 20)
        view.addSubview(mainScreen)
        
        currentScreen = mainScreen
        
        mainScreen.newLine()
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CalculatorViewController.handlePanGesture(_:))))
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(CalculatorViewController.handlePinchGesture(_:))))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if currentScreen is GraphScreen {
            let translation: CGPoint = sender.translation(in: self.view)
            
            graphScreen.center = CGPoint(x: graphScreen.center.x + translation.x, y: graphScreen.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
            
            let xScale: Double = graphScreen.cartesianBounds.xRange / Double(graphScreen.frame.size.width)
            let yScale: Double = graphScreen.cartesianBounds.yRange / Double(graphScreen.frame.size.height)
            
            var newBounds = CartesianBounds(xMin: graphScreen.cartesianBounds.xMin, xMax: graphScreen.cartesianBounds.xMax, xStep: graphScreen.cartesianBounds.xStep, yMin: graphScreen.cartesianBounds.yMin, yMax: graphScreen.cartesianBounds.yMax, yStep: graphScreen.cartesianBounds.yStep)
            
            newBounds.xMin += xScale * Double(translation.x)
            newBounds.xMax += xScale * Double(translation.x)
            newBounds.yMin += yScale * Double(translation.y)
            newBounds.yMax += yScale * Double(translation.y)
            
            graphScreen.updateGraph(oldBounds: graphScreen.cartesianBounds, newBounds: newBounds)
        }
    }
    
    func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        
    }
    
    func showPad(pad: UIView, top: CGFloat, animated: Bool, completion: ((Bool) -> Void)?) {
        UIView.animate(
            withDuration: (animated ? 0.2 : 0),
            animations: { 
                pad.frame = CGRect(x: 0, y: top, width: pad.frame.size.width, height: self.view.frame.size.height - top)
            },
            completion: completion
        )
    }
    
    func hidePad(pad: UIView, animated: Bool, completion: ((Bool) -> Void)?) {
        UIView.animate(
            withDuration: (animated ? 0.2 : 0),
            animations: {
                pad.frame.origin.y = self.view.bounds.size.height
            },
            completion: completion
        )
    }
    
    func openSettings() {
        let settingsPad: SettingsPad = SettingsPad(frame: view.bounds)
        settingsPad.frame.origin.y = view.frame.size.height
        settingsPad.delegate = self
        
        view.addSubview(settingsPad)
        
        showPad(
            pad: settingsPad,
            top: 0,
            animated: true
        ) { (completed) in
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    // MARK: ButtonPadDelegate methods
    
    func sendText(text: String, fromPad pad: ButtonPad) {
        if currentScreen is ButtonPadDelegate {
            (currentScreen as! ButtonPadDelegate).sendText(text: text, fromPad: pad)
        }
    }
    
    func buttonPressed(_ button: Button, onPad pad: ButtonPad) {
        if currentScreen is ButtonPadDelegate {
            (currentScreen as! ButtonPadDelegate).buttonPressed(button, onPad: pad)
        }
    }
    
    func keyPressed(_ key: Key, onPad pad: ButtonPad) {
        if pad is ModePad {
            if key.activeTitle.lowercased() == "main" {
                currentScreen = mainScreen
            } else if key.activeTitle.lowercased() == "functions" {
                currentScreen = functionScreen
            } else if key.activeTitle.lowercased() == "bounds" {
                currentScreen = boundsScreen
            } else if key.activeTitle.lowercased() == "graph" {
                currentScreen = graphScreen
            } else if key.activeTitle.lowercased() == "table" {
                currentScreen = tableScreen
            }
            
            pad.removeFromSuperview()
        } else if pad is MainPad {
            if key.activeTitle.lowercased() == "\u{2699}" {
                openSettings()
            } else if key.activeTitle.lowercased() == "use\nfunctions" {
                let functionPad: FunctionPad = FunctionPad(frame: pad.frame)
                functionPad.delegate = self
                view.addSubview(functionPad)
            } else if key.activeTitle.lowercased() == "mode" {
                let modePad: ModePad = ModePad(frame: pad.frame)
                modePad.delegate = self
                
                if currentScreen is MainScreen {
                    modePad.disableButtons(withTitles: ["Main"])
                } else if currentScreen is FunctionScreen {
                    modePad.disableButtons(withTitles: ["Functions"])
                } else if currentScreen is BoundsScreen {
                    modePad.disableButtons(withTitles: ["Bounds"])
                } else if currentScreen is GraphScreen {
                    modePad.disableButtons(withTitles: ["Graph"])
                }
                
                view.addSubview(modePad)
            } else if key.activeTitle.lowercased() == "const" {
                let constPad: ConstantPad = ConstantPad(frame: pad.frame)
                constPad.delegate = self
                view.addSubview(constPad)
            } else {
                if currentScreen is ButtonPadDelegate {
                    (currentScreen as! ButtonPadDelegate).keyPressed(key, onPad: pad)
                }
            }
        } else if pad is GraphPad {
            if key.activeTitle.lowercased() == "main" {
                currentScreen = mainScreen
            } else if key.activeTitle.lowercased() == "edit\nfunctions" {
                currentScreen = functionScreen
            } else if key.activeTitle.lowercased() == "bounds" {
                currentScreen = boundsScreen
            }
        } else if pad is FunctionPad {
            if currentScreen is ButtonPadDelegate {
                (currentScreen as! ButtonPadDelegate).keyPressed(key, onPad: pad)
            }
            
            pad.removeFromSuperview()
        } else if pad is SettingsPad && key.activeIdentifier?.lowercased() == "quit" {
            UIApplication.shared.statusBarStyle = .default
            
            hidePad(pad: pad, animated: true, completion: { (completed) in
                pad.removeFromSuperview()
            })
        } else if pad is PadView && key.activeIdentifier?.lowercased() == "quit" {
            pad.removeFromSuperview()
        }
    }
    
    func togglePressed(_ toggle: Toggle, onPad pad: ButtonPad) {
        if currentScreen is ButtonPadDelegate {
            (currentScreen as! ButtonPadDelegate).togglePressed(toggle, onPad: pad)
        }
    }
    
    func disableButtons(pad: ButtonPad) {}
    
}
