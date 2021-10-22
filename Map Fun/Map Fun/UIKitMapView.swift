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
  internal var mapView: MapView!
  internal var cameraLocationConsumer: CameraLocationConsumer!
  let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoiY3J5c3RhbGsiLCJhIjoiY2t2MmN1aXNiMGZhdjMwcXBqZ2ZhdWZveiJ9.gcln_rzBgW6Tj-508UHlDw")
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func draw(_ rect: CGRect) {
      let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: CameraOptions(zoom: 15.0))
    
      mapView = MapView(frame: self.bounds, mapInitOptions: myMapInitOptions)
      mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       
      self.addSubview(mapView)
      
      cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
      
      mapView.location.options.puckType = .puck2D()
      
    mapView.mapboxMap.onNext(.mapLoaded) { _ in
        self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)
      }
  }
}

public class CameraLocationConsumer: LocationConsumer {
  weak var mapView: MapView?
  
  init(mapView: MapView) {
    self.mapView = mapView
  }
  
  public func locationUpdate(newLocation: Location) {
    mapView?.camera.ease(
      to: CameraOptions(center: newLocation.coordinate, zoom: 15),
      duration: 1.3)
  }
}
