//
//  MotionDetector.swift
//  Seismometer
//
//  Created by fasih zaidi on 23/07/2024.
//
import CoreMotion
import UIKit

class MotionDetector: ObservableObject {
    private let motionManager = CMMotionManager()

    private var timer = Timer()
    private var updateInterval: TimeInterval

    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var zAcceleration: Double = 0

    var onUpdate: (() -> Void) = {}
    
    private var currentOrientation: UIDeviceOrientation = .landscapeLeft
    private var orientationObserver: NSObjectProtocol? = nil
    let orientationNotification = UIDevice.orientationDidChangeNotification

    init(updateInterval: TimeInterval) {
        self.updateInterval = updateInterval
    }
    
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            
            timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
                self.updateMotionData()
            }
        } else {
            print("Device motion not available")
        }
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        orientationObserver = NotificationCenter.default.addObserver(forName: orientationNotification, object: nil, queue: .main) { [weak self] _ in
            switch UIDevice.current.orientation {
            case .faceUp, .faceDown, .unknown:
                break
            default:
                self?.currentOrientation = UIDevice.current.orientation
            }
        }
    }
    
    func updateMotionData() {
        if let data = motionManager.deviceMotion {
            (roll, pitch) = currentOrientation.adjustedRollAndPitch(data.attitude)
            zAcceleration = data.userAcceleration.z

            onUpdate()
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        timer.invalidate()
        if let orientationObserver = orientationObserver {
            NotificationCenter.default.removeObserver(orientationObserver, name: orientationNotification, object: nil)
        }
        orientationObserver = nil
    }

    deinit {
        stop()
    }
}

extension MotionDetector {
    func started() -> MotionDetector {
        start()
        return self
    }
}

extension UIDeviceOrientation {
    func adjustedRollAndPitch(_ attitude: CMAttitude) -> (roll: Double, pitch: Double) {
        switch self {
        case .unknown, .faceUp, .faceDown:
            return (attitude.roll, -attitude.pitch)
        case .landscapeLeft:
            return (attitude.pitch, -attitude.roll)
        case .portrait:
            return (attitude.roll, attitude.pitch)
        case .portraitUpsideDown:
            return (-attitude.roll, -attitude.pitch)
        case .landscapeRight:
            return (-attitude.pitch, attitude.roll)
        @unknown default:
            return (attitude.roll, attitude.pitch)
        }
    }
}
