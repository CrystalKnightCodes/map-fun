//
//  MapController.swift
//  Map Fun
//
//  Created by Crystal Knight on 10/22/21.
//  Based on examples found here: https://docs.mapbox.com/ios/beta/maps/examples/

import MapboxMaps
import CoreLocation
import SwiftUI

class MapController: ObservableObject {
  // MARK: - Properties
  @Published var isRecording = false
  @Published var currentRoute = [CLLocationCoordinate2D]()
  
  private var currentIndex = -1
  var timer: Timer?
  
  private var routeLineSource = GeoJSONSource()
  
  public var mapView: MapView!
  private var cameraLocationConsumer: CameraLocationConsumer!
  
  let mapInitOptions = MapInitOptions(
    resourceOptions: ResourceOptions(
      accessToken: String.accessToken
    ),
    cameraOptions: CameraOptions(
      center: CLLocationCoordinate2D(latitude: 35, longitude: 35),
      zoom: 15
    ),
    styleURI: .streets
  )
  
  // Initialization
  // UIKit initializer passes in frame to conform to view.bounds
  // SwiftUI initializer will reset frame based on screen size, so default value is used.
  init(frame: CGRect = CGRect(x: 0, y: 0, width: 64, height: 64)) {
    mapView = MapView(frame: frame, mapInitOptions: mapInitOptions)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
    
    mapView.location.options.puckType = .puck2D()
    
    mapView.mapboxMap.onNext(.mapLoaded) { _ in
      // Register location consumer with map
      self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)
    }
  }
  
  // SwiftUI initializer will reset frame based on screen sized, so default value is used.

  
  deinit {
    timer?.invalidate()
    timer = nil
  }
  
  // MARK: - Methods
  public func recordRoute() {
    guard isRecording else { return }
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
      if self.isRecording {
        self.addCoordinate()
      } else {
        timer.invalidate()
      }
    })
  }
  
  /// Deletes current route and removes it from the map.
  public func deleteRoute() {
    currentRoute = []
    currentIndex = -1
    try? mapView.mapboxMap.style.removeLayer(withId: String.lineLayerID)
    try? mapView.mapboxMap.style.removeSource(withId: String.routeSourceID)
  }
  
  /// Add coordinate to current route.
  private func addCoordinate() {
    guard let currentCoordinate = self.mapView.location.latestLocation?.coordinate else { return }
    // Only record location if it has changed.
    if currentRoute.isEmpty || currentRoute.last != currentCoordinate {
      currentRoute.append(currentCoordinate)
      currentIndex += 1
      self.addLine()
    }
  }
  
  /// Create first line segment.
  private func prepLine() {
    routeLineSource.data = .feature(Feature(geometry: .lineString(LineString([currentRoute[currentIndex]]))))
    
    // Create a line layer
    var lineLayer = LineLayer(id: String.lineLayerID)
    lineLayer.source = String.routeSourceID
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
    try! mapView.mapboxMap.style.addSource(routeLineSource, id: String.routeSourceID)
    try! mapView.mapboxMap.style.addLayer(lineLayer, layerPosition: .below(String.puckLayerID))
  }
  
  /// Add line segments based on coordinates in current route.
  private func addLine() {
    guard !currentRoute.isEmpty else { return }
    // If this is a new line, prep the first segment.
    if currentRoute.count == 1 {
      self.prepLine()
    }
    
    let updatedLine = Feature(geometry: .lineString(LineString(currentRoute)))
    self.routeLineSource.data = .feature(updatedLine)
    try! self.mapView.mapboxMap.style.updateGeoJSONSource(
      withId: String.routeSourceID,
      geoJSON: .feature(updatedLine)
    )
  }
}

// MARK: - Helpers
// Updates map to user's current location.
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
