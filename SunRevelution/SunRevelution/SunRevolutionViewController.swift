//
//  SunRevolutionViewController.swift
//  SunRevelution
//
//  Created by mac126 on 2018/3/19.
//  Copyright © 2018年 mac126. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class SunRevolutionViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let sunNode = SCNNode()
    let earthNode = SCNNode()
    let moonNode = SCNNode()
    let moonRotationNode = SCNNode() // 月球绕地球公转
    let earthGroupNode = SCNNode() // 地球和月球作为一个节点，绕太阳公转
    let sunHaloNode = SCNNode() // 太阳光晕
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // 视图是否更新场景的灯光，默认为true
        sceneView.automaticallyUpdatesLighting = true
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        
        self.initNode()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //  是否启用光照估计默认为ture，自适应灯光（从室内到室外画面比较柔和）
        configuration.isLightEstimationEnabled = true
        
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
    
    func initNode() {
        sunNode.geometry = SCNSphere(radius: 3)
        earthNode.geometry = SCNSphere(radius: 1)
        moonNode.geometry = SCNSphere(radius: 0.5)
        
        // 渲染图
        sunNode.geometry?.firstMaterial?.multiply.contents = "art.scnassets/earth/sun.jpg"
        sunNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun.jpg"
        sunNode.geometry?.firstMaterial?.multiply.intensity = 0.5 // 强度
        sunNode.geometry?.firstMaterial?.lightingModel = .constant
        
        earthNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/earth-diffuse-mini.jpg"
        // 地球夜光图
        earthNode.geometry?.firstMaterial?.emission.contents = "art.scnassets/earth/earth-emissive-mini.jpg"
        earthNode.geometry?.firstMaterial?.specular.contents = "art.scnassets/earth/earth-specular-mini.jpg"
        
        moonNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/moon.jpg"
        
        // 设置位置
        sunNode.position = SCNVector3(0, 5, -20)
        earthGroupNode.position = SCNVector3(10, 0, 0)
        earthNode.position = SCNVector3(3, 0, 0)
        moonRotationNode.position = earthNode.position
        moonNode.position = SCNVector3(3, 0, 0)
        
        // rootnote为sun，sun上添加earth， earth添加moon
        moonRotationNode.addChildNode(moonNode)
        earthGroupNode.addChildNode(earthNode)
        earthGroupNode.addChildNode(moonRotationNode)
        
        sunNode.addChildNode(earthGroupNode)
        self.sceneView.scene.rootNode.addChildNode(sunNode)
    }
    
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
