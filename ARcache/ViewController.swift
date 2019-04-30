//
//  ViewController.swift
//  ARcache
//
//  Created by Jaeson Booker on 2/13/19.
//  Copyright © 2019 Jaeson Booker. All rights reserved.
//
//import stuff
import UIKit
import SceneKit
import ARKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    var arAnchor: ARAnchor?
    var cacheFoundAudioPlayer = AVAudioPlayer()
    var cacheOpenAudioPlayer = AVAudioPlayer()
    //var currentNode: SCNNode!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var firstMessage: UILabel!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var cacheMessage: UILabel!
    var locationManager = CLLocationManager()
    var cacheArray: [Cache] = []
    var isOpen: Bool = false
    var hitVectorStorage: SCNVector3?
    var touchesBeginning: Bool = false
    @IBOutlet var sceneView: ARSCNView!
    @IBAction func startHorizontalAction(_ sender: Any) {
//        let openCacheShape = SCNBox(width: 0.07, height: 0.2, length: 0.2, chamferRadius: 0.1)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "starman")
//        //diffuse (how light renders), contents (appearance of material)
//        openCacheShape.materials = [material]
//        //cacheNode.geometry = cacheShape
//        let openCacheNode = SCNNode(geometry: openCacheShape)
//        if hitVectorStorage != nil {
//            openCacheNode.position = hitVectorStorage!
//        }
//        sceneView.scene.rootNode.addChildNode(openCacheNode)
//        //create logic for objects inside cache
//        let objectShape = SCNSphere(radius: 0.1)
//        let objectMaterial = SCNMaterial()
//        objectMaterial.diffuse.contents = UIImage(named: "sunny")
//        //diffuse (how light renders), contents (appearance of material)
//        objectShape.materials = [objectMaterial]
//        //cacheNode.geometry = cacheShape
//        let treasureNode = SCNNode(geometry: objectShape)
//        if hitVectorStorage != nil {
//            treasureNode.position = SCNVector3(x: hitVectorStorage!.x+0.1, y: hitVectorStorage!.y, z: hitVectorStorage!.z-0.1)
//        }
//        sceneView.scene.rootNode.addChildNode(treasureNode)
        if isOpen{
            isOpen = false
            cacheMessage.isHidden = true
            cacheButton.isHidden = false
            openCacheButton.isHidden = true
            addButton.isHidden = true
            takeButton.isHidden = true
        } else {
            isOpen = true
            insertCacheButton.isHidden = true
            cacheMessage.isHidden = false
            addButton.isHidden = false
            takeButton.isHidden = false
            cacheMessage.text = cacheArray[1].notes[1]
            
            if let objectAnchor = arAnchor as? ARObjectAnchor {
                
                //create text for plane
                let planeText = SCNText(string: cacheArray[1].notes[1], extrusionDepth: 2.0)
                planeText.firstMaterial?.diffuse.contents = UIColor.white
                //planeText.font = UIFont(name: "Arial", size: 1)
                let planeTextNode = SCNNode(geometry: planeText)
                planeTextNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x-0.5, objectAnchor.referenceObject.center.y, objectAnchor.referenceObject.center.z-1.7)
                planeTextNode.scale = SCNVector3(0.001,0.001,0.001)
                sceneView.scene.rootNode.addChildNode(planeTextNode)
            
                //create plane for text
                let plane = SCNPlane(width: CGFloat(0.4), height: CGFloat(0.2))
                let material2 = SCNMaterial()
                material2.diffuse.contents = UIImage(named: "dragon")
                plane.materials = [material2]
                let planeNode = SCNNode(geometry: plane)
                planeNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x-0.5, objectAnchor.referenceObject.center.y, objectAnchor.referenceObject.center.z-1.7)
                cacheOpenAudioPlayer.play()
                sceneView.scene.rootNode.addChildNode(planeNode)
                
            }
            removeRenderedCache()
            openCacheButton.setTitle("Close", for: .normal)
        }
    }
    @IBOutlet weak var emailLabel: UILabel!
    @IBAction func takeCacheItem(_ sender: Any) {
        cacheMessage.text = "You have successfully taken the note: \(cacheArray[1].notes[0]) WRITE IT SOMEWHERE BEFORE PRESSING CLOSE!"
        cacheArray[1].notes[0] = "Note already taken! Should have been quicker!"
        let editedCache = Cache(notes: cacheArray[1].notes, xcoordinate: cacheArray[1].xcoordinate, ycoordinate: cacheArray[1].ycoordinate)
        guard let url = URL(string: "https://arcache.vapor.cloud/caches/2") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonBody = try JSONEncoder().encode(editedCache)
            request.httpBody = jsonBody
        } catch {}
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, _, _) in
            guard let data = data else { return }
            do {
                let sentPatch = try JSONDecoder().decode(Cache.self, from: data)
                print(sentPatch)
                print("I am here in the sent Update")
            } catch {}
        }
        task.resume()
    }
    @IBAction func addCacheItem(_ sender: Any) {
        insertCacheButton.isHidden = false
        cacheMessage.text = "Fantastic! You're contributing to society! Now add the message you want to place in the cache! Examples: Simple greeting, game code, short poem, anything!"
        firstMessage.text = "Your note"
        inputStackView.isHidden = false
        emailLabel.isHidden = true
        emailField.isHidden = true
        openCacheButton.isHidden = true
        takeButton.isHidden = true
        addButton.isHidden = true
    }
    @IBAction func startCache(_ sender: Any) {
        cacheButton.isHidden = true
        cacheMessage.isHidden = false
        cacheMessage.text = "Tap on screen where you want to place cache. It's best for it to be in a well-lit environment. On a smooth, vertical surface that can be written on."
        touchesBeginning = true
    }
    @IBAction func insertCacheButton(_ sender: Any) {
        if isOpen{
            var messageSubmission: String = ""
            if messageField.text != nil {
                messageSubmission = messageField.text!
            }
            cacheArray[1].notes.append(messageSubmission)
            let editedCache = Cache(notes: cacheArray[1].notes, xcoordinate: cacheArray[1].xcoordinate, ycoordinate: cacheArray[1].ycoordinate)
            guard let url = URL(string: "https://arcache.vapor.cloud/caches/2") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonBody = try JSONEncoder().encode(editedCache)
                request.httpBody = jsonBody
            } catch {}
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, _, _) in
                guard let data = data else { return }
                do {
                    let sentPatch = try JSONDecoder().decode(Cache.self, from: data)
                    print(sentPatch)
                    print("I am here in the sent Update")
                } catch {}
            }
            task.resume()
            self.cacheMessage.text = "Congrats! You've just added to an Arcache! Happy hunting!"
            self.firstMessage.text = "First Message!"
            self.inputStackView.isHidden = true
            self.insertCacheButton.isHidden = true
            self.emailLabel.isHidden = false
            self.emailField.isHidden = false
            self.addButton.isHidden = false
            openCacheButton.isHidden = false
            takeButton.isHidden = false
        } else {
            var lat: Double = 0.0
            var longi: Double = 0.0
            var messageSubmission: String = ""
            var emailSubmission: String = ""
            if messageField.text != nil {
                messageSubmission = messageField.text!
            }
            if emailField.text != nil {
                emailSubmission = emailField.text!
            }
            if locationManager.location?.coordinate != nil {
                lat = (locationManager.location?.coordinate.latitude)!
                longi = (locationManager.location?.coordinate.longitude)!
            }
            let newCache = Cache(notes: [emailSubmission, messageSubmission], xcoordinate: lat, ycoordinate: longi)
            guard let url = URL(string: "https://arcache.vapor.cloud/caches") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonBody = try JSONEncoder().encode(newCache)
                request.httpBody = jsonBody
            } catch {}
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, _, _) in
                guard let data = data else { return }
                do {
                    let sentPost = try JSONDecoder().decode(Cache.self, from: data)
                    print(sentPost)
                    print("i am here in the sent Post")
                } catch {}
            }
            task.resume()
            self.cacheMessage.text = "X marks the spot. Draw an X in the real world where the ArCache is, preferably over a white background. That way, other people will be able to find it!"
            self.inputStackView.isHidden = true
            self.insertCacheButton.isHidden = true
        }
    }
    @IBOutlet weak var cacheButton: UIButton!
    @IBOutlet weak var openCacheButton: UIButton!
    @IBOutlet weak var insertCacheButton: UIButton!
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        messageField.resignFirstResponder()
        emailField.resignFirstResponder()
    }
    override func viewDidLoad() {
//        //FOR TESTING
//        self.sceneView.session.currentFrame?.rawFeaturePoints?.points
//        sceneView.debugOptions =
//            [ARSCNDebugOptions.showFeaturePoints]
//        sceneView.debugOptions =
//            [ARSCNDebugOptions.showFeaturePoints,
//             ARSCNDebugOptions.showWorldOrigin]
//        sceneView.showsStatistics = true
        super.viewDidLoad()
        //get the sound
        let cacheFoundSound = Bundle.main.path(forResource: "cacheFound", ofType: "mp3")
        let cacheOpenSound = Bundle.main.path(forResource: "cacheOpen", ofType: "mp3")
        do {
            cacheFoundAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: cacheFoundSound!))
            cacheOpenAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: cacheOpenSound!))
        }
        catch {
            print(error)
        }
        //getting API
        guard let url = URL(string: "https://arcache.vapor.cloud/caches") else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let apiEvents = try JSONDecoder().decode([Cache].self, from: data)
                //looping through decoded caches
                for apiEvent in apiEvents {
                    // appending caches to array
                    self.cacheArray.append(apiEvent)
                    print(apiEvent)
                }
            } catch { }
        }
        task.resume()
//        var newCache = Cache(notes: ["note!!", "notey"], xcoordinate: 0.1, ycoordinate: 0.2)
//        var newCache2 = Cache(notes: ["note!!", "notey"], xcoordinate: 37.779890, ycoordinate: -122.421910)
//        self.cacheArray.append(newCache)
//        self.cacheArray.append(newCache2)
        print("complete")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        //        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //        // Set the scene to the view
        //        sceneView.scene = scene
        //registerGestureRecognizer()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        let scene = SCNScene()
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
        //sceneView.session.run(imageConfiguration)
        
        sceneView.session.run(configuration)
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
            insertCacheButton.isHidden = false
            //NOTE: Not everyone knows what a cache is
            cacheMessage.text = "Great! Now add the first message you want to place in the cache! Examples: Simple greeting, game code, short poem, anything! And give your new cache a name."
            inputStackView.isHidden = false
            //openCacheButton.isHidden = false
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        arAnchor = anchor
        let node = SCNNode()
        if locationManager.location?.coordinate != nil {
            let userX = (locationManager.location?.coordinate.latitude)!
            let userY = (locationManager.location?.coordinate.longitude)!
            for i in cacheArray {
                if (i.xcoordinate >= (userX-0.1)) && (i.xcoordinate <= (userX+0.1)) && (i.ycoordinate >= (userY-0.1)) && (i.ycoordinate <= (userY+0.1)) {
                    if let objectAnchor = anchor as? ARObjectAnchor {
                        let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x * 0.8), height: CGFloat(objectAnchor.referenceObject.extent.y * 0.5))
                        let box = SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0.00001)
                        plane.cornerRadius = plane.width * 0.125
                        let displayScene = SKScene(fileNamed: "cacheScene")
                        let material = SCNMaterial()
                        material.diffuse.contents = UIImage(named: "dragon2")
                        plane.firstMaterial?.diffuse.contents = displayScene
                        plane.firstMaterial!.isDoubleSided = true
                        plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                        box.materials = [material]
                        let planeNode = SCNNode(geometry: plane)
                        let cacheNode = SCNNode(geometry: box)
                        planeNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.35, objectAnchor.referenceObject.center.z)
                        cacheNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.35, objectAnchor.referenceObject.center.z)
                        cacheNode.name = "renderedCacheNode"
                        node.addChildNode(cacheNode)
                        
                        cacheFoundAudioPlayer.play()
                    }
                    self.openCacheButton.isHidden = false
                    self.cacheButton.isHidden = true
                    break
                }
            }
        }
        print("anchor made")
        return node
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            print("rendering!")
            let openCacheShape = SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0.00001)
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "wood")
            //diffuse (how light renders), contents (appearance of material)
            openCacheShape.materials = [material]
            //cacheNode.geometry = cacheShape
            let openCacheNode = SCNNode(geometry: openCacheShape)
            //       sceneView.scene.rootNode.addChildNode(openCacheNode)
            guard anchor is ARImageAnchor else { return }
            //container, yo
            if isOpen{
                guard let openContainer = sceneView.scene.rootNode.childNode(withName: "openContainer", recursively: false) else { return }
                openContainer.removeFromParentNode()
                node.addChildNode(openContainer)
                //node.addChildNode(openCacheNode)
                openContainer.isHidden = false
            } else {
                guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else { return }
                container.removeFromParentNode()
                node.addChildNode(container)
                //node.addChildNode(openCacheNode)
                container.isHidden = false
            }
            openCacheButton.isHidden = false
            cacheButton.isHidden = true
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
        let cacheShape = SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0.00001)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "dragon2")
        //diffuse (how light renders), contents (appearance of material)
        cacheShape.materials = [material]
        //cacheNode.geometry = cacheShape
//        guard let cacheScene = SCNScene(named: "art.scnassets/ship.scn") else { return }
//        guard let cacheSceneNode = cacheScene.rootNode.childNode(withName: "empty", recursively: false) else { return }
//        let physicsShape = SCNPhysicsShape(node: cacheSceneNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
//        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
//        cacheSceneNode.physicsBody = physicsBody
//        cacheSceneNode.position = position
//        sceneView.scene.rootNode.addChildNode(cacheSceneNode)
        let cacheNode = SCNNode(geometry: cacheShape)
        cacheNode.position = position
        cacheNode.name = "cacheNode"
        sceneView.scene.rootNode.addChildNode(cacheNode)
    }
    func removeCache(){
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "cacheNode" {
                node.removeFromParentNode()
            }
        }
    }
    func removeRenderedCache(){
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "renderedCacheNode" {
                node.removeFromParentNode()
            }
        }
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
