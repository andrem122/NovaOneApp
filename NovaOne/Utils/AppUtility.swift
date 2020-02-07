//
//  AppUtility.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/6/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

struct AppUtility {
    
    // Allows locking of the device to potrait mode on a specific view
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }

}
