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

class RoomCaptureViewController: UIViewController, RoomCaptureSessionDelegate {
    
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet private weak var exportButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var isScanning: Bool = false
    
    private var roomCaptureView: RoomCaptureView?
    private let roomCaptureSessionConfig = RoomCaptureSession.Configuration()
    
    private var finalResults: CapturedRoom?

    private var sceneView: SCNView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoomCaptureView()
        activityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ flag: Bool) {
        super.viewWillDisappear(flag)
        stopSession()
    }
    
    private func setupRoomCaptureView() {
        let roomCaptureView = RoomCaptureView(frame: view.bounds)
            view.insertSubview(roomCaptureView, at: 0)
        roomCaptureView.delegate = self
            self.roomCaptureView = roomCaptureView
     
    }
    
      private func startSession() {
          isScanning = true
          roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
          setActiveNavBar()
      }
      
      private func stopSession() {
          isScanning = false
          roomCaptureView?.captureSession.stop()
          setCompleteNavBar()
      }
  
    private func setActiveNavBar() {
        UIView.animate(withDuration: 1.0, animations: {
            self.cancelButton?.tintColor = .white
            self.doneButton?.tintColor = .white
            self.exportButton?.alpha = 0.0
        }, completion: { complete in
            self.exportButton?.isHidden = true
        })
    }
    
    private func setCompleteNavBar() {
        self.exportButton?.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.cancelButton?.tintColor = .systemBlue
            self.doneButton?.tintColor = .systemBlue
            self.exportButton?.alpha = 1.0
        }
    }
    
    @IBAction func cancelScanning(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
    
    @IBAction func doneScanning(_ sender: UIBarButtonItem) {
        if isScanning { stopSession() } else { cancelScanning(sender) }
        self.exportButton?.isEnabled = false
        self.activityIndicator?.startAnimating()
    }
    
    @IBAction func exportResults(_ sender: UIButton) {
        if let viewController = self.storyboard?.instantiateViewController(
            withIdentifier: "CustomViewController")  as? CustomViewController {
            viewController.finalResults = finalResults
            navigationController?.pushViewController(viewController, animated: true)
        }
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
            finalResults = processedResult
        self.exportButton?.isEnabled = true
        self.activityIndicator?.stopAnimating()
       
    }
}
