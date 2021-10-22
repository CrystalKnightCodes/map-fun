//
//  UIKitMapView.swift
//  Map Fun
//
//  Created by Crystal Knight on 10/22/21.
//  Based on examples found here: https://docs.mapbox.com/ios/beta/maps/examples/

import UIKit
import MapboxMaps
import CoreLocation

class UIKitMapView: UIView {
  // MARK: - Properties
  // Recording
  var isRecording = false
  var timer: Timer?
  
  // Route
  var route = [CLLocationCoordinate2D]()
  var currentIndex = -1
  public var geoJSONLine = (identifer: "routeLine", source: GeoJSONSource())
  internal let sourceID = "route-source-identifier"
  internal var routeLineSource: GeoJSONSource!
  
  // Init & Deinit
  internal var mapView: MapView!
  internal var cameraLocationConsumer: CameraLocationConsumer!
  let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoiY3J5c3RhbGsiLCJhIjoiY2t2MmN1aXNiMGZhdjMwcXBqZ2ZhdWZveiJ9.gcln_rzBgW6Tj-508UHlDw")
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  deinit {
    timer?.invalidate()
    timer = nil
  }
  
  // MARK: - View
  override func draw(_ rect: CGRect) {
    // Set initial camera settings
    let center = CLLocationCoordinate2D(latitude: 35, longitude: 35)
    let camera = CameraOptions(center: center, zoom: 15)
    let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: camera, styleURI: .streets)
    
    mapView = MapView(frame: self.bounds, mapInitOptions: myMapInitOptions)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    self.addSubview(mapView)
    
    cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
    
    // Add user's position icon
    mapView.location.options.puckType = .puck2D()
    
    // Receive info about map events
    mapView.mapboxMap.onNext(.mapLoaded) { _ in
      // Register location consumer with map
      self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)
    }
  }
  
  // MARK: - Methods
  func recordRoute() {
    guard isRecording else { return }
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
      if self.isRecording {
        self.addCoordinate()
      } else {
        timer.invalidate()
      }
    })
  }
  
  func deleteRoute() {
    route = []
    currentIndex = -1
    try? mapView.mapboxMap.style.removeLayer(withId: "line-layer")
    try? mapView.mapboxMap.style.removeSource(withId: sourceID)
  }
  
  func addCoordinate() {
    guard let currentCoordinate = self.mapView.location.latestLocation?.coordinate else { return }
    // Only record location if it has changed.
    if route.isEmpty || route.last != currentCoordinate {
      print("Adding coordinate \(currentCoordinate)")
      route.append(currentCoordinate)
      currentIndex += 1
      self.addLine()
    }
  }
  
  // Create first line segment.
  func prepLine() {
    routeLineSource = GeoJSONSource()
    routeLineSource.data = .feature(Feature(geometry: .lineString(LineString([route[currentIndex]]))))
    
    // Create a line layer
    var lineLayer = LineLayer(id: "line-layer")
    lineLayer.source = sourceID
    lineLayer.lineColor = .constant(StyleColor(.green))
    
    let lowZoomWidth = 5
    let highZoomWidth = 20
    
    // Use an expression to define the line width at different zoom extents
    lineLayer.lineWidth = .expression(
      Exp(.interpolate) {
        Exp(.linear)
        Exp(.zoom)
        14
        lowZoomWidth
        18
        highZoomWidth
      }
    )
    lineLayer.lineCap = .constant(.round)
    lineLayer.lineJoin = .constant(.round)

    // Add the lineLayer to the map.
    try! mapView.mapboxMap.style.addSource(routeLineSource, id: sourceID)
    try! mapView.mapboxMap.style.addLayer(lineLayer, layerPosition: .below("puck"))
  }
  
  func addLine() {
    guard !route.isEmpty else { return }
    // If this is a new line, prep the first segment.
    if route.count == 1 {
      self.prepLine()
    }
    
    let updatedLine = Feature(geometry: .lineString(LineString(route)))
    self.routeLineSource.data = .feature(updatedLine)
    try! self.mapView.mapboxMap.style.updateGeoJSONSource(withId: self.sourceID,
                                                          geoJSON: .feature(updatedLine))
  }
}

// MARK: - Helpers
public class CameraLocationConsumer: LocationConsumer {
  weak var mapView: MapView?
  
  init(mapView: MapView) {
    self.mapView = mapView
  }
  
  public func locationUpdate(newLocation: Location) {
    mapView?.camera.ease(
      to: CameraOptions(center: newLocation.coordinate, zoom: 15),
      duration: 0.75)
  }
}
