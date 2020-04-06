//
//  ViewController.swift
//  ARDicee
//
//  Created by FGT MAC on 4/5/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        setupDice()
        
        //setupSphere()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       setupTracking()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    // MARK: - Custom Methods
    
    func setupTracking() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //Dectect horizontal plane = flat surface ex. floor or table
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func setupDice() {

        //Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        //Set the scene to the view, recursively = to allow access down the direcotry to finde idnetifier Dice
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            
            diceNode.position = SCNVector3(0, 0, -0.01)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
        }
        
        //Add lighting for true 3d effects/shodows
        sceneView.autoenablesDefaultLighting = true
    }
    
    
    func setupSphere() {

         let sphere = SCNSphere(radius: 0.2)

         let material = SCNMaterial()

         material.diffuse.contents = UIImage(named: "art.scnassets/2k_mercury.jpg")

         sphere.materials = [material]

         let node = SCNNode()

         node.position = SCNVector3(0, 0.1, -0.5)

         node.geometry = sphere

         sceneView.scene.rootNode.addChildNode(node)
         
         //Add lighting for true 3d effects/shodows
         sceneView.autoenablesDefaultLighting = true
    }
    
    
    //MARK: - ARSCNViewDelegate
    
    //Tell delegate when a horizontal surface has been detected
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }

}
