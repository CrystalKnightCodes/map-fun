//
//  UIKitMapViewController.swift
//  Map Fun
//
//  Created by Crystal Knight on 10/22/21.
//

import UIKit

class UIKitMapViewController: UIViewController {
  // MARK: - Properties
  // Outlets
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var mapView: UIKitMapView!
  
  // Actions
  @IBAction func recordButtonTapped(_ sender: UIButton) {
    mapView.mapController.isRecording.toggle()
    mapView.mapController.recordRoute()
    setImage()
  }
  
  @IBAction func deleteRouteTapped(_ sender: UIButton) {
    mapView.mapController.deleteRoute()
  }
  
  // MARK: - View
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Methods
  func setImage() {
    if mapView.mapController.isRecording {
      recordButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
    } else {
      recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
    }
  }
}



