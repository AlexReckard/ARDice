//
//  ViewController.swift
//  ARDice
//
//  Created by Alex Reckard on 12/5/19.
//  Copyright © 2019 Alex Reckard. All rights reserved.
//

// texture maps 3d squid
// dae collada file
// the units are in meters

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.delegate = self
        
        
        sceneView.autoenablesDefaultLighting = true
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

    };
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {
            
            let worldConfiguration = ARWorldTrackingConfiguration()
            
            worldConfiguration.planeDetection = .horizontal
            
            print("World Tracking is supported = \(ARWorldTrackingConfiguration.isSupported)")
       
            sceneView.session.run(worldConfiguration)
            
        } else {
            
            let oriConfiguration = AROrientationTrackingConfiguration()
            
            print("Session is supported = \(AROrientationTrackingConfiguration.isSupported)")
           
            sceneView.session.run(oriConfiguration)
            
        };
    };
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    };
    
    // MARK: - Dice Rendering Methods
    
    // touch detection and placing 3D model using touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResults = results.first {
                print(hitResults)
                addDice(atLocation: hitResults)
            };
        };
    };
    
    // external internal param
    func addDice(atLocation location : ARHitTestResult) {
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

        // recursively will search through the tree to find the correct identity
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
           
           // simd_float4x4 scale, rotation, position and matrix 4x4 with x,y,z,w
           diceNode.position = SCNVector3(
               x: location.worldTransform.columns.3.x,
               // raises the object above the grid correctly
               y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
               z: location.worldTransform.columns.3.z
           );
           
           diceArray.append(diceNode)

           sceneView.scene.rootNode.addChildNode(diceNode)
           
        };
    };
    
    // animate objects in 3D
    func roll(dice: SCNNode) {
        // random 4 faces between 1-4 shifted up by 1 * 90 "degrees". y axis doesn't really need the rotation
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)

        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)

        // multiplied the x and z to make the dice roll more "realistic"
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 6),
                y: 0,
                z: CGFloat(randomZ * 6),
                duration: 0.3)
        );
    };
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            };
        };
    };
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    };
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    };
    
    @IBAction func removeDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            };
        };
    };

    // MARK: - ARSCNViewDelegate Methods
    
    // horizontal plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
//        if anchor is ARPlaneAnchor {
//
//            let planeAnchor = anchor as! ARPlaneAnchor
//
//        } else {
//            return
//        };
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)

    };
    
    // MARK: - Plane Rendering Methods
    
    // make sure it returns as an SCNNode so it can be used in the renderer func
    func createPlane(withPlaneAnchor planeAnchor : ARPlaneAnchor) -> SCNNode {
        
        // plane anchor is always 2D positioned ONLY in x and zed positions

        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

        let planeNode = SCNNode()

        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)

        // in radians -Float.pi/2 rotating plane 90 degrees clockwise "angle, x, y, z"
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)

        let gridMaterial = SCNMaterial()

        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")

        plane.materials = [gridMaterial]

        planeNode.geometry = plane
        
        return planeNode
    };
};
