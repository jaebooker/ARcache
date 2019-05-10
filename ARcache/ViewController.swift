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
    
    @IBOutlet weak var addressStack: UIStackView!
    @IBOutlet weak var nameInput: UITextField!
    
    @IBOutlet weak var streetInput: UITextField!
    
    @IBOutlet weak var countryInput: UITextField!
    var arAnchor: ARAnchor?
    var cacheFoundAudioPlayer = AVAudioPlayer()
    var cacheOpenAudioPlayer = AVAudioPlayer()
    var cacheCloseAudioPlayer = AVAudioPlayer()
    //var currentNode: SCNNode!
    @IBAction func removeActionTest(_ sender: Any) {
        let imageConfiguration = ARImageTrackingConfiguration()
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "PhotoAnchors", bundle: nil) else { return }
        imageConfiguration.trackingImages = arImages
        sceneView.session.run(imageConfiguration) // Run the view's session
    }
    @IBOutlet weak var removeLabelTest: UIButton!
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
        if isOpen{
            isOpen = false
            cacheMessage.isHidden = true
            cacheButton.isHidden = false
            openCacheButton.isHidden = true
            addButton.isHidden = true
            takeButton.isHidden = true
            closeRenderedCache()
        } else {
            //if not open, open
            isOpen = true
            insertCacheButton.isHidden = true
            cacheMessage.isHidden = false
            addButton.isHidden = false
            takeButton.isHidden = false
            cacheMessage.text = "nutty!"
            cacheOpenAudioPlayer.play()
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
        cacheMessage.text = "Tap on screen where you want to place cache. It's best for it to be in a well-lit environment, on a smooth, vertical surface where you can place a sticker."
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
            self.cacheMessage.text = "Great! Now you're going to need to add a sticker so the camera knows where the cache is! Add your address, so we can send you a free sticker."
            self.inputStackView.isHidden = true
            self.insertCacheButton.isHidden = true
            self.addressStack.isHidden = false
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
        let cacheCloseSound = Bundle.main.path(forResource: "cacheClose", ofType: "mp3")
        do {
            cacheFoundAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: cacheFoundSound!))
            cacheOpenAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: cacheOpenSound!))
            cacheCloseAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: cacheCloseSound!))
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
        //for testing
//        var newCache = Cache(notes: ["note!!", "notey"], xcoordinate: 0.1, ycoordinate: 0.2)
//        var newCache2 = Cache(notes: ["note!!", "notey"], xcoordinate: 37.779890, ycoordinate: -122.421910)
//        self.cacheArray.append(newCache)
//        self.cacheArray.append(newCache2)
        print("complete")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "CacheAnchors", bundle: Bundle.main)!
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
//            inputStackView.isHidden = false
            removeLabelTest.isHidden = false
            //openCacheButton.isHidden = false
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        arAnchor = anchor
        print(arAnchor)
        let node = SCNNode()
        if locationManager.location?.coordinate != nil {
            let userX = (locationManager.location?.coordinate.latitude)!
            let userY = (locationManager.location?.coordinate.longitude)!
            for i in cacheArray {
                if (i.xcoordinate >= (userX-0.1)) && (i.xcoordinate <= (userX+0.1)) && (i.ycoordinate >= (userY-0.1)) && (i.ycoordinate <= (userY+0.1)) {
                    if let objectAnchor = anchor as? ARObjectAnchor {
                        let plane = SCNPlane(width: 0.3, height: 0.2)
                        let box = SCNBox(width: 0.2, height: 0.1, length: 0.00001, chamferRadius: 0.00001)
                        let box2 = SCNBox(width: 0.00001, height: 0.1, length: 0.1, chamferRadius: 0.00001)
                        let box3 = SCNBox(width: 0.2, height: 0.00001, length: 0.1, chamferRadius: 0.00001)
                        let openBox = SCNBox(width: 0.2, height: 0.08, length: 0.00001, chamferRadius: 0.00001)
                        plane.cornerRadius = plane.width * 0.125
                        let material = SCNMaterial()
                        material.diffuse.contents = UIImage(named: "dragon2")
                        let material2 = SCNMaterial()
                        material2.diffuse.contents = UIImage(named: "dragon")
                        plane.materials = [material2]
                        box.materials = [material]
                        box2.materials = [material]
                        box3.materials = [material]
                        openBox.materials = [material]
                        let planeNode = SCNNode(geometry: plane)
                        let cacheNodeSide1 = SCNNode(geometry: box)
                        let cacheNodeSide2 = SCNNode(geometry: box)
                        let cacheNodeSide3 = SCNNode(geometry: box2)
                        let cacheNodeSide4 = SCNNode(geometry: box2)
                        let cacheNodeSide5 = SCNNode(geometry: box3)
                        let cacheNodeSide6 = SCNNode(geometry: box3)
                        let openCacheNodeSide = SCNNode(geometry: openBox)
                        planeNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.61, objectAnchor.referenceObject.center.z-0.05)
                        cacheNodeSide1.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.35, objectAnchor.referenceObject.center.z)
                        cacheNodeSide2.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.35, objectAnchor.referenceObject.center.z - 0.1)
                        cacheNodeSide3.position = SCNVector3Make(objectAnchor.referenceObject.center.x - 0.1, objectAnchor.referenceObject.center.y + 0.35, objectAnchor.referenceObject.center.z - 0.05)
                        cacheNodeSide4.position = SCNVector3Make(objectAnchor.referenceObject.center.x + 0.1, objectAnchor.referenceObject.center.y + 0.35, objectAnchor.referenceObject.center.z-0.05)
                        cacheNodeSide5.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.40, objectAnchor.referenceObject.center.z-0.05)
                        cacheNodeSide6.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.30, objectAnchor.referenceObject.center.z-0.05)
                        openCacheNodeSide.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.44, objectAnchor.referenceObject.center.z - 0.1)
                        cacheNodeSide1.name = "cacheNodeSide1"
                        cacheNodeSide2.name = "cacheNodeSide2"
                        cacheNodeSide3.name = "cacheNodeSide3"
                        cacheNodeSide4.name = "cacheNodeSide4"
                        cacheNodeSide5.name = "cacheNodeSide5"
                        cacheNodeSide6.name = "cacheNodeSide6"
                        openCacheNodeSide.name = "openCacheNodeSide"
                        openCacheNodeSide.isHidden = true
                        node.addChildNode(cacheNodeSide1)
                        node.addChildNode(cacheNodeSide2)
                        node.addChildNode(cacheNodeSide3)
                        node.addChildNode(cacheNodeSide4)
                        node.addChildNode(cacheNodeSide5)
                        node.addChildNode(cacheNodeSide6)
                        node.addChildNode(openCacheNodeSide)
                        //node.addChildNode(cacheNode2)
                        //create text for plane
                        let planeText = SCNText(string: cacheArray[0].notes[0], extrusionDepth: 2.0)
                        planeText.firstMaterial?.diffuse.contents = UIColor.white
                        let planeTextNode = SCNNode(geometry: planeText)
                        planeTextNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.61, objectAnchor.referenceObject.center.z-0.05)
                        planeTextNode.scale = SCNVector3(0.001,0.001,0.001)
                        planeNode.isHidden = true
                        planeTextNode.isHidden = true
                        planeNode.name = "planeNode"
                        planeTextNode.name = "planeTextNode"
                        node.addChildNode(planeTextNode)
                        node.addChildNode(planeNode)
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

    func createCache(position: SCNVector3) {
        let cacheShape = SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0.00001)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "dragon2")
        //diffuse (how light renders), contents (appearance of material)
        cacheShape.materials = [material]
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
            if node.name == "cacheNodeSide5" {
                node.isHidden = true
            }
            if node.name == "openCacheNodeSide" {
                node.isHidden = false
            }
            if node.name == "planeTextNode" {
                node.isHidden = false
            }
            if node.name == "planeNode" {
                node.isHidden = false
            }
        }
    }
    func closeRenderedCache(){
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "cacheNodeSide5" {
                node.isHidden = false
            }
            if node.name == "openCacheNodeSide" {
                node.isHidden = true
            }
            if node.name == "planeTextNode" {
                node.isHidden = true
            }
            if node.name == "planeNode" {
                node.isHidden = true
            }
            cacheCloseAudioPlayer.play()
        }
    }
    func getRenderedCacheAnchor() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "renderedCacheNode" {
                let plane = SCNPlane(width: 0.2, height: 0.3)
                let box = SCNBox(width: 0.1, height: 0.1, length: 0.2, chamferRadius: 0.00001)
                plane.cornerRadius = plane.width * 0.125
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(named: "dragon2")
                let material2 = SCNMaterial()
                material2.diffuse.contents = UIImage(named: "dragon")
                plane.materials = [material2]
                box.materials = [material]
                let planeNode = SCNNode(geometry: plane)
                let cacheNode2 = SCNNode(geometry: box)
                planeNode.position = node.position
                cacheNode2.position = node.position
                cacheNode2.name = "cacheNode2"
                sceneView.scene.rootNode.addChildNode(cacheNode2)
            }
        }
    }
    
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
