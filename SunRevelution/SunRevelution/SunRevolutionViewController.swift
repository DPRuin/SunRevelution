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
        self.sunRotation()
        self.earthTurn()
        self.sunTurn()
        self.addLight()
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
    
    /// 初始化节点信息
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
    
    /// 设置太阳自转
    func sunRotation() {
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.duration = 10.0
        animation.toValue = SCNVector4(0, 1, 0, Double.pi * 2) // 绕y轴转动
        animation.repeatCount = Float.greatestFiniteMagnitude // 有限幅度最大
        sunNode.addAnimation(animation, forKey: "sunRotation")
    }
    
    
    /**
     月球如何围绕地球转呢
     可以把月球放到地球上，让地球自转月球就会跟着地球，但是月球的转动周期和地球的自转周期是不一样的，所以创建一个月球围绕地球节点（与地球节点位置相同），让月球放到地月节点上，让这个节点自转，设置转动速度即可
     */
    /// 设置地球自转和月亮围绕地球转
    func earthTurn() {
        // 地球自转
        earthNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)), forKey: "earthRotation")
        
        // 月球自转
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.duration = 1.5
        animation.toValue = SCNVector4(0, 1, 0, Double.pi * 2)
        animation.repeatCount = Float.greatestFiniteMagnitude
        moonNode.addAnimation(animation, forKey: "moonRotation")
        
        // 月球公转
        let moonRotationAnimation = CABasicAnimation(keyPath: "rotation")
        moonRotationAnimation.duration = 5
        moonRotationAnimation.toValue = SCNVector4(0, 1, 0, Double.pi * 2)
        moonRotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        moonRotationNode.addAnimation(moonRotationAnimation, forKey: "moonRotationAroundEarth")
        
    }
    
    /// 地球公转
    func sunTurn() {
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.duration = 10
        animation.toValue = SCNVector4(0, 1, 0, Double.pi * 2)
        animation.repeatCount = Float.greatestFiniteMagnitude
        earthGroupNode.addAnimation(animation, forKey: "earthRotationAroundSun")
    }
    
    
    /// 设置太阳光晕和光线照到的地方
    func addLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.color = UIColor.red
        sunNode.addChildNode(lightNode)
        lightNode.light?.attenuationEndDistance = 20.0 // 光照亮度随着距离改变
        lightNode.light?.attenuationStartDistance = 1.0
        
        // MARK: - SCNTransaction??事务
        // SCNTransaction??事务
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        
        lightNode.light?.color = UIColor.white
        lightNode.opacity = 0.5 // 不透明度，默认为1
        SCNTransaction.commit()
        
        sunHaloNode.geometry = SCNPlane(width: 25, height: 25)
        sunHaloNode.rotation = SCNVector4(1, 0, 0,Float(0 * Double.pi / 180))
        sunHaloNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun-halo.png"
        sunHaloNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        
        // 确定接收者在呈现时是否写入深度缓冲区,默认为true
        sunHaloNode.geometry?.firstMaterial?.writesToDepthBuffer = false // 不要有厚度，看起来薄薄的一层
        sunHaloNode.opacity = 5
        sunNode.addChildNode(sunHaloNode)
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
