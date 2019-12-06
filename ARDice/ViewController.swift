//
//  ViewController.swift
//  ARDice
//
//  Created by Alex Reckard on 12/5/19.
//  Copyright © 2019 Alex Reckard. All rights reserved.
//

// texture maps 3d squid
// dae collada file

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.delegate = self
        
        // the units are in meters
        // chamfer is the roundness of corners
        
        // examples
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//
//        let sphere = SCNSphere(radius: 0.2)
//
//        let material = SCNMaterial()
//
//        // for texture maps UIImage(named: "art.scnassets/8k_moon.jpg")
//        material.diffuse.contents = UIColor.red
//
//        sphere.materials = [material]
//
//        let node = SCNNode()
//
//        // zed goes away from you - or towards you +
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//
//        node.geometry = cube
//
//      sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        // recursively will search through the tree to find the correct identity
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        
            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1 )
        
            sceneView.scene.rootNode.addChildNode(diceNode)
        };
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
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
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
            
            node.addChildNode(planeNode)
         
        } else {
            return
        }
    }
}
