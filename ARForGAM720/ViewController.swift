//
//  AppDelegate.swift
//  ARForGAM720
//
//  Created by Rachel Saunders on 01/05/2020.
//  Copyright © 2020 Rachel Saunders. All rights reserved.
//


// SceneKit needed for 3D scene, ARKit obviously for AR
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // links up to scene view on storyboard
    @IBOutlet var sceneView: ARSCNView!
    
    
var animations = [String: CAAnimation]()
    
    // start off the animation idle
    var idle:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Load the DAE animations, func declared below
        loadAnimations()
    }
    
    func loadAnimations () {
        // Load the character in the idle animation
        // Changed to the 3D model I rigged
        let idleScene = SCNScene(named: "art.scnassets/Idle.dae")!
        
        // This node will be parent of all the animation models
        let node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        // position of the node in AR
        node.position = SCNVector3(0, -1, -2)
        node.scale = SCNVector3(0.2, 0.2, 0.2)
        
        // Adds the node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        // Load the movement animation
    
        // Changed to the 3D model I rigged
        loadAnimation(withKey: "walking", sceneName: "art.scnassets/WalkingFixed", animationIdentifier: "WalkingFixed-1")
    }
    
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
    
        // Usual scene coding for dae files
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        // animation properties, play once, fade in and out is to make it look less "choppy"
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
          
            animationObject.repeatCount = 1
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            // Store the animation
            animations[withKey] = animationObject
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        // Let's test if a 3D Object was touch
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
        
        if hitResults.first != nil {
            if(idle) {
                playAnimation(key: "walking")
            } else {
                stopAnimation(key: "walking")
            }
            idle = !idle
            return
        }
    }
    
    func playAnimation(key: String) {
        // Add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
