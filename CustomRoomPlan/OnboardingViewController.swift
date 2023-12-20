//
//  OnboardingViewController.swift
//  CustomRoomPlan
//
//  Created by Oleh on 20.12.2023.
//

import UIKit

class OnboardingViewController:
    UIViewController {
    @IBAction func startScan(_ sender: UIButton) {
        if let viewController = self.storyboard?.instantiateViewController(
            withIdentifier: "RoomCaptureViewNavigationController") {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }
}
