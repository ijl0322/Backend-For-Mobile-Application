//
//  GameViewController.swift
//  KoiPond
//
//  Created by Isabel  Lee on 10/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    @IBAction func myButton(_ sender: UIButton) {
        //SharedNetworking.sharedInstance.simplePost()
        ActionTracker.tracker.button1Clicked += 1
        print("Button 1 Total Clicks: \(ActionTracker.tracker.button1Clicked)")
    }
    
    @IBAction func button2(_ sender: UIButton) {
        ActionTracker.tracker.button2Clicked += 1
        print("Button 2 Total Clicks: \(ActionTracker.tracker.button2Clicked)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func ripple() {
        let animation = CATransition()
        animation.delegate = self.view as? CAAnimationDelegate
        animation.duration = 5.0
        animation.timingFunction = CAMediaTimingFunction(name : kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = "rippleEffect"
        self.view.layer.add(animation, forKey: nil)
    }
}
