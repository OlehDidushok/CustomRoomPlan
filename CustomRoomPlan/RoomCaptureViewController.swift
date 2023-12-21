//
//  ViewController.swift
//  CustomRoomPlan
//
//  Created by Oleh on 20.12.2023.
//

import UIKit
import RealityKit
import ARKit
import RoomPlan

class RoomCaptureViewController: UIViewController {

//    @IBOutlet weak var arView: ARView!
    private var roomCaptureView: RoomCaptureView?
    private let roomCaptureSessionConfig = RoomCaptureSession.Configuration()
    private var sceneView: SCNView?
    
    // Setup RoomBuilder
    private var roomBuilder = RoomBuilder(options: [.beautifyObjects])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let roomCaptureView = RoomCaptureView(frame: view.bounds)
            view.insertSubview(roomCaptureView, at: 0)
            self.roomCaptureView = roomCaptureView
        startSession()
    }
    
      private func startSession() {
          roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
      }
      
      private func stopSession() {
          roomCaptureView?.captureSession.stop()
      }
    
    private func onModelReady(model: CapturedRoom) {
        let walls = getAllNodes(for: model.walls,
                                length: 0.1,
                                contents: UIImage(named: "wallTexture"))
        walls.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let doors = getAllNodes(for: model.doors,
                                length: 0.11,
                                contents: UIImage(named: "doorTexture"))
        doors.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let windows = getAllNodes(for: model.windows,
                                  length: 0.11,
                                  contents: UIImage(named: "windowTexture"))
        windows.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let openings = getAllNodes(for: model.openings,
                                  length: 0.11,
                                   contents: UIColor.blue.withAlphaComponent(0.5))
        openings.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        
        getAllRoomObjectsCategory(model: model).forEach { category in
                    let scannedObjects = model.objects.filter { $0.category == category }
                    let objectsNode = getAllNodes(for: scannedObjects, category: category)
                    objectsNode.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
                }
    }
    
    private func getAllRoomObjectsCategory(model: CapturedRoom) -> [CapturedRoom.Object.Category] {
        model.objects.compactMap { $0 as? CapturedRoom.Object.Category }
    }
    
    private func getModelName(from category: CapturedRoom.Object.Category) -> String {
        String("\(category.self)")
    }
    
    
    private func getAllNodes(for objects: [CapturedRoom.Object], category: CapturedRoom.Object.Category) -> [SCNNode] {
        var nodes: [SCNNode] = []
        let modelName = getModelName(from: category)
        if let objectUrl = Bundle.main.url(forResource: modelName, withExtension: "usdz"),
           let objectScene = try? SCNScene(url: objectUrl),
           let objectNode = objectScene.rootNode.childNodes.first {
            objects.enumerated().forEach { index, object in
                let node = objectNode.clone()
                node.transform = SCNMatrix4(object.transform)
                nodes.append(node)
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
            nodes.append(node)
        }
        return nodes
    }
}

extension RoomCaptureViewController:  RoomCaptureViewDelegate {
    
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        true
    }
    
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        if let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        do {
            if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let url = directory.appendingPathComponent("scanned.usdz")
                try processedResult.export(to: url)
                
                // Share or save model to file
                let shareVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                present(shareVC, animated: true, completion: nil)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
