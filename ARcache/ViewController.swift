//
//  ViewController.swift
//  ARcache
//
//  Created by Jaeson Booker on 2/13/19.
//  Copyright © 2019 Jaeson Booker. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    //var currentNode: SCNNode!
    var hitVectorStorage: SCNVector3?
    var touchesBeginning: Bool = false
    @IBOutlet var sceneView: ARSCNView!
    @IBAction func startHorizontalAction(_ sender: Any) {
        let openCacheShape = SCNBox(width: 0.07, height: 0.2, length: 0.2, chamferRadius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "starman")
        //diffuse (how light renders), contents (appearance of material)
        openCacheShape.materials = [material]
        //cacheNode.geometry = cacheShape
        let openCacheNode = SCNNode(geometry: openCacheShape)
        if hitVectorStorage != nil {
            openCacheNode.position = hitVectorStorage!
        }
        sceneView.scene.rootNode.addChildNode(openCacheNode)
        //create logic for objects inside cache
        let objectShape = SCNSphere(radius: 0.1)
        let objectMaterial = SCNMaterial()
        objectMaterial.diffuse.contents = UIImage(named: "sunny")
        //diffuse (how light renders), contents (appearance of material)
        objectShape.materials = [objectMaterial]
        //cacheNode.geometry = cacheShape
        let treasureNode = SCNNode(geometry: objectShape)
        if hitVectorStorage != nil {
            treasureNode.position = SCNVector3(x: hitVectorStorage!.x+0.1, y: hitVectorStorage!.y, z: hitVectorStorage!.z-0.1)
        }
        sceneView.scene.rootNode.addChildNode(treasureNode)
        insertCacheButton.isHidden = true
        openCacheButton.setTitle("Close", for: .normal)
    }
    @IBAction func startCache(_ sender: Any) {
        cacheButton.isHidden = true
        insertCacheButton.isHidden = false
        touchesBeginning = true
    }
    @IBAction func insertCacheButton(_ sender: Any) {
    }
    @IBOutlet weak var cacheButton: UIButton!
    @IBOutlet weak var openCacheButton: UIButton!
    @IBOutlet weak var insertCacheButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //        // Set the scene to the view
        //        sceneView.scene = scene
        //registerGestureRecognizer()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //let scene = SCNScene()
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "CacheAnchors", bundle: Bundle.main)!
        let imageConfiguration = ARImageTrackingConfiguration()
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "PhotoAnchors", bundle: nil) else { return }
        imageConfiguration.trackingImages = arImages
        // Run the view's session
        sceneView.session.run(imageConfiguration)
        //sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touchesBeginning == true) {
            guard let touch = touches.first else {return}
            let result = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
            guard let hitResult = result.last else {return}
            //let hitTransform = hitResult.worldTransform
            let hitTransform = SCNMatrix4.init(hitResult.worldTransform)
            //        let hitTransform = SCNMatrix4FromGLKMatrix4(hitResult?.worldTransform)
            let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
            hitVectorStorage = hitVector
            createCache(position: hitVector)
            touchesBeginning = false
            insertCacheButton.isHidden = true
            openCacheButton.isHidden = false
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        print("anchor made")
        let node = SCNNode()
        if let objectAnchor = anchor as? ARObjectAnchor {
            let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x * 0.8), height: CGFloat(objectAnchor.referenceObject.extent.y * 0.5))
            plane.cornerRadius = plane.width * 0.125
            let displayScene = SKScene(fileNamed: "cacheScene")
            plane.firstMaterial?.diffuse.contents = displayScene
            plane.firstMaterial!.isDoubleSided = true
            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.35, objectAnchor.referenceObject.center.z)
            node.addChildNode(planeNode)
        }
        return node
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            print("rendering!")
            let openCacheShape = SCNBox(width: 0.07, height: 0.2, length: 0.2, chamferRadius: 0.1)
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "starman")
            //diffuse (how light renders), contents (appearance of material)
            openCacheShape.materials = [material]
            //cacheNode.geometry = cacheShape
            let openCacheNode = SCNNode(geometry: openCacheShape)
            //       sceneView.scene.rootNode.addChildNode(openCacheNode)
            guard anchor is ARImageAnchor else { return }
            //container, yo
            guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else { return }
        
            container.removeFromParentNode()
            node.addChildNode(container)
            //node.addChildNode(openCacheNode)
            container.isHidden = false
        }
//        if let objectAnchor = anchor as? ARObjectAnchor {
//            let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x *0.8), height: CGFloat(objectAnchor.referenceObject.extent.y *0.5))
//            plane.cornerRadius = plane.width
//            let spriteKitScene = SKScene(fileNamed: "ship")
//            plane.firstMaterial?.diffuse.contents = spriteKitScene
//            plane.firstMaterial?.isDoubleSided = true
//            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
//            let planeNode = SCNNode(geometry: plane)
//            planeNode.position = SCNVector3(CGFloat(objectAnchor.referenceObject.center.x), CGFloat(objectAnchor.referenceObject.center.y + 0.35), CGFloat(objectAnchor.referenceObject.center.z))
//            node.addChildNode(planeNode)
//        }
//        return node
//    }
    //let cacheNode: SCNNode?
    func createCache(position: SCNVector3) {
        let cacheShape = SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "texture")
        //diffuse (how light renders), contents (appearance of material)
        cacheShape.materials = [material]
        //cacheNode.geometry = cacheShape
        guard let cacheScene = SCNScene(named: "art.scnassets/ship.scn") else { return }
        guard let cacheSceneNode = cacheScene.rootNode.childNode(withName: "cache", recursively: false) else { return }
        let physicsShape = SCNPhysicsShape(node: cacheSceneNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        cacheSceneNode.physicsBody = physicsBody
        sceneView.scene.rootNode.addChildNode(cacheSceneNode)
        //let cacheNode = SCNNode(geometry: cacheShape)
        cacheSceneNode.position = position
        sceneView.scene.rootNode.addChildNode(cacheSceneNode)
    }
//    func registerGestureRecognizer(){
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        sceneView.addGestureRecognizer(tap)
//
//    }
//    func addCache() {
//        guard let cacheScene = SCNScene(named: "art.scnassets/ship.scn") else { return }
//        guard let cacheSceneNode = cacheScene.rootNode.childNode(withName: "cache", recursively: false) else { return }
//        cacheSceneNode.position = SCNVector3(0, 0.5, -3)
//        let physicsShape = SCNPhysicsShape(node: cacheSceneNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
//        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
//        cacheSceneNode.physicsBody = physicsBody
//        sceneView.scene.rootNode.addChildNode(cacheSceneNode)
//        print("cacheSceneNode added")
////        horizontalAction(node:cacheSceneNode)
//        roundAction(node: cacheSceneNode)
//        currentNode = cacheSceneNode
//    }
//    func horizontalAction(node:SCNNode){
//        let leftAction = SCNAction.move(by: SCNVector3(-1,0,0), duration: 3)
//        let rightAction = SCNAction.move(by: SCNVector3(1,0,0), duration: 3)
//        let actionSeqeunce = SCNAction.sequence([leftAction,rightAction])
//        node.runAction(SCNAction.repeat(actionSeqeunce, count: 4))
//    }
//    func roundAction(node: SCNNode){
//        let upLeft = SCNAction.move(by: SCNVector3(1,1,0),duration: 2)
//        let downRight = SCNAction.move(by: SCNVector3(1,-1,0),duration: 2)
//        let downLeft = SCNAction.move(by: SCNVector3(-1,-1,0),duration: 2)
//        let upRight = SCNAction.move(by: SCNVector3(-1,1,0),duration: 2)
//        let actionSeqeunce = SCNAction.sequence([upLeft,downRight,downLeft,upRight])
//        node.runAction(SCNAction.repeat(actionSeqeunce, count: 4))
//    }
//    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer){
//        //scene view
//        //access point of view (center point)
//        guard let sceneView = gestureRecognizer.view as? ARSCNView else { return }
//        guard let centerPoint = sceneView.pointOfView else { return }
//        //now have transform matrix, with orientation & camera location
//        let cameraTransformer = centerPoint.transform
//        let cameraLocation = SCNVector3(cameraTransformer.m41,cameraTransformer.m42,cameraTransformer.m43)
//        let cameraOrientation = SCNVector3(-cameraTransformer.m31,-cameraTransformer.m32,-cameraTransformer.m33)
//        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
//        // x1 + x2, y1 + y2, z1 + z2 ^
//        let box = SCNSphere(radius: 25)
//        let natural = SCNMaterial()
//        natural.diffuse.contents = UIImage(named: "texture.png")
//        //diffuse (how light renders), contents (appearance of material)
//        box.materials = [natural]
//        let boxNode = SCNNode(geometry: box)
//        //must be node^
//        boxNode.position = cameraPosition
//        let physicsShape = SCNPhysicsShape(node: boxNode, options: nil)
//        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
//        boxNode.physicsBody = physicsBody
//        //let forceVector: Float = 6
//        boxNode.physicsBody?.applyForce(SCNVector3(cameraPosition.x*250,cameraPosition.y*250,cameraPosition.z*250), asImpulse: true)
//        sceneView.scene.rootNode.addChildNode(boxNode)
//    }
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
