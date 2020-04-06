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
    
    //MARK: - Properties
    
    var diceArray = [SCNNode]()
    
    
    //MARK: - View lifecycle

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //place dots on plane
        //debugAR()
        
        // Set the view's delegate
        sceneView.delegate = self
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

    //MARK: - Actions
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        removeAll()
    }
    
    
    // MARK: - Custom Methods
    
    func debugAR() {
        
        //Use to display points where system is trying to dectect surfaces
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
    }
    
    func setupTracking() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //Dectect horizontal plane = flat surface ex. floor or table
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func setupDice(x: Float, y: Float, z: Float) {
        
        //Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        //Set the scene to the view, recursively = to allow access down the direcotry to finde idnetifier Dice
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            
            //Modified to make it appear on top of the plane and not half way throught the plane
            let modifiedY = y + diceNode.boundingSphere.radius
            
            diceNode.position = SCNVector3(x, modifiedY, z)
            
            //Add dices to array
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        
        //Create random number to rotate dice, Y axis doe not need to be rotate because it the vertical so is not necesary
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        //Create the animation, multiple by 5 to make the turns look faster
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5))
    }
    
    func removeAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
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
    
    func makePlane(withPlaneAnchor planeAnchor: ARPlaneAnchor ) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        //Rotate
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
    }
    
    
    //MARK: - ARSCNViewDelegate
    
    //Tell delegate when a horizontal surface has been detected
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            
        let planeNode = makePlane(withPlaneAnchor: planeAnchor)
            
            //Added to the scene
            node.addChildNode(planeNode)
    }

    //Detects when user touches areas on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //If we enable multitouch then we can access the array of taps but at moment is not enable
        //But every time we tap a new object will be place
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            
            //THis basically translates the 2d touch in out screen to a point in a 3d space in the image
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                //Position object where the user tap on the screen
                let xPosition = hitResult.worldTransform.columns.3.x
                let yPosition = hitResult.worldTransform.columns.3.y
                let zPosition = hitResult.worldTransform.columns.3.z
                
                //Setup the dice passing the tap position
                setupDice(x: xPosition, y: yPosition, z: zPosition)
            }
        }
    }
    
    //If we shake the phone the the rollAll method will be invoke
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
}
