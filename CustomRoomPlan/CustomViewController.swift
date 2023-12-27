//
//  CustomViewController.swift
//  CustomRoomPlan
//
//  Created by Oleh on 22.12.2023.
//

import UIKit
import SceneKit
import RoomPlan

class CustomViewController: UIViewController {
    
    var finalResults: CapturedRoom?
    
    @IBOutlet weak var sceneView: SCNView!
    let scene = SCNScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.lightGray
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene?.rootNode.removeFromParentNode()
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = true
//        sceneView.scene?.background.contents = UIColor.gray
        
        if let finalResults {
            onModelReady(model: finalResults)        }
    }
    
    private func onModelReady(model: CapturedRoom) {
        let walls = getAllNodes(for: model.walls,
                                length: 0.1,
                                contents: UIImage(named: "wallTexture"))
        walls.forEach {
            scene.rootNode.addChildNode($0) }
        let doors = getAllNodes(for: model.doors,
                                length: 0.11,
                                contents: UIImage(named: "doorTexture"))
        doors.forEach {
            scene.rootNode.addChildNode($0) }
        let windows = getAllNodes(for: model.windows,
                                  length: 0.11,
                                  contents: UIImage(named: "windowTexture"))
        windows.forEach {
            scene.rootNode.addChildNode($0)}
        let openings = getAllNodes(for: model.openings,
                                   length: 0.11,
                                   contents: UIColor.blue.withAlphaComponent(0.5))
        openings.forEach {
            scene.rootNode.addChildNode($0)
            
        }
        
        getAllRoomObjectsCategory(model: model).forEach { category in
            let scannedObjects = model.objects.filter { $0.category == category }
            let objectsNode = getAllNodes(for: scannedObjects, category: category)
            objectsNode.forEach {
                scene.rootNode.addChildNode($0)
            }
        }
        
        for node in scene.rootNode.childNodes {
            print("NODE name\(node.name)" + "NODE position\(node.simdPosition)")
        }
    }
    
    private func getAllRoomObjectsCategory(model: CapturedRoom) -> [CapturedRoom.Object.Category] {
        return model.objects.map { ($0.category) }
    }
    
    private func getModelName(from category: CapturedRoom.Object.Category) -> String {
        String("\(category.self)")
    }
    
    
    private func getAllNodes(for objects: [CapturedRoom.Object], category: CapturedRoom.Object.Category) -> [SCNNode] {
        var nodes: [SCNNode] = []
        let modelName = getModelName(from: category)
        if let objectUrl = Bundle.main.url(forResource: modelName, withExtension: "dae"),
           let objectScene = try? SCNScene(url: objectUrl),
           let objectNode = objectScene.rootNode.childNodes.first {
            objects.enumerated().forEach { index, object in
                print("\(object.category)"+"  "+" \(object.dimensions.y.magnitude)"+"  "+"\(object.dimensions.x.magnitude)"+"  "+"\(object.dimensions.z.magnitude)")
                let node = objectNode.clone()
                node.transform = SCNMatrix4(object.transform)
                node.name = String("\(object.category)")
                
                print("\(node.name)" + "\(node.height)"+"  "+"\(node.width)"+"  "+"\(node.length)")
                nodes.append(node)
//                node.scale = SCNVector3(x: 0.0037, y:  0.0029, z:  0.0035)
            }
        }
        return nodes
    }
    
    private func getAllNodes(for surfaces: [CapturedRoom.Surface], length: CGFloat, contents: Any?) -> [SCNNode] {
        var nodes: [SCNNode] = []
        surfaces.forEach { surface in
            let width = CGFloat(surface.dimensions.x)
            let height = CGFloat(surface.dimensions.y)
            let node = SCNNode()
            node.geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
            node.geometry?.firstMaterial?.diffuse.contents = contents
            node.transform = SCNMatrix4(surface.transform)
            node.name = String("\(surface.category)")
            print("\(node.name)" + "\(node.height)"+"  "+"\(node.width)"+"  "+"\(node.length)")
            nodes.append(node)
        }
        return nodes
    }
    
}

extension SCNNode {
    
    var height: CGFloat { CGFloat(self.boundingBox.max.y - self.boundingBox.min.y) }
    var width: CGFloat { CGFloat(self.boundingBox.max.x - self.boundingBox.min.x) }
    var length: CGFloat { CGFloat(self.boundingBox.max.z - self.boundingBox.min.z) }
    
    var halfCGHeight: CGFloat { height / 2.0 }
    var halfHeight: Float { Float(height / 2.0) }
    var halfScaledHeight: Float { halfHeight * self.scale.y  }
}
