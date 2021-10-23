//
//  UIKitMapView.swift
//  Map Fun
//
//  Created by Crystal Knight on 10/22/21.
//  

import UIKit
import MapboxMaps

class UIKitMapView: UIView {
  // MARK: - Properties
  public var mapView: MapView!
  public var mapController: MapController!
  
  // Initialization
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  deinit {
    mapController.timer?.invalidate()
  }
  
  // MARK: - View
  override func draw(_ rect: CGRect) {
    // Set initial focus settings
    mapController = MapController(frame: self.bounds)
    mapView = mapController.mapView
    
    self.addSubview(mapView)
  }
}

  
