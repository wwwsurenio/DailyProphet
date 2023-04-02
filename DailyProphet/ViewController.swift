//
//  ViewController.swift
//  DailyProphet
//
//  Created by User01 on 2/4/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var player = AVPlayer()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "NewsPaperImages", bundle: Bundle.main){
            
            configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 1
            
        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
       
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let videoNode: SKVideoNode? = {
                
                guard let urlString = Bundle.main.path(forResource: "harrypotter", ofType: "mp4") else {
                    
                    return nil
                    
                }
                
                let url = URL(fileURLWithPath: urlString)
                
                let item = AVPlayerItem(url: url)
                
                player = AVPlayer(playerItem: item)
                
                return SKVideoNode(avPlayer: player)
                
            }()
            
            let videoScene = SKScene(size: CGSize(width: 480, height: 360))
            
            videoNode?.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
            
            videoNode?.yScale = -1.0 //'-' will flip image rightside up
            
            videoScene.addChild(videoNode!)
            
            player.play()
            
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            // look at image file to determine its physical size so the plane is the same size as the image
            
            plane.firstMaterial?.diffuse.contents = videoScene
            
            let planeNode = SCNNode(geometry: plane)
            
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil)
            
            { notification in
                
                self.player.seek(to: CMTime.zero)
                
                self.player.play()
                
            }
            
        }
        
        return node
        
    }
    
}
