//
//  SwiftUIMapView.swift
//  Map Fun
//
//  Created by Crystal Knight on 10/23/21.
//

import SwiftUI
import MapboxMaps
import CoreLocation


struct SwiftUIMap: UIViewRepresentable {
  // MARK: - Map Properties
  @Binding private var camera: Camera
  @Binding public var mapController: MapController
  
  // Init
  init(camera: Binding<Camera>, controller: Binding<MapController>) {
    _camera = camera
    _mapController = controller
  }
  
  // MARK: - Map Methods
  func makeCoordinator() -> SwiftUIMapViewCoordinator {
    SwiftUIMapViewCoordinator(camera: $camera)
  }
  
  func makeUIView(context: UIViewRepresentableContext<SwiftUIMap>) -> MapView {
    context.coordinator.mapView = mapController.mapView
    
    updateUIView(mapController.mapView, context: context)
    
    return mapController.mapView
  }
  
  func updateUIView(_ map: MapView, context: Context) {
    context.coordinator.performWithoutObservation {
      map.mapboxMap.setCamera(to: CameraOptions(center: camera.center, zoom: camera.zoom))
    }
  }
}

// Coordinates the map with the camera
final class SwiftUIMapViewCoordinator {
  // MARK: - Coordinator Properties
  @Binding private var camera: Camera
  
  var mapView: MapView! {
    didSet {
      cancelable?.cancel()
      cancelable = nil
      
      cancelable = mapView.mapboxMap.onEvery(.cameraChanged) { [unowned self] (event) in
        notify(for: event)
      }
    }
  }
  
  private var cancelable: Cancelable?
  private var ignoreNotifications = false
  
  // Initialization
  init(camera: Binding<Camera>) {
    _camera = camera
  }
  
  deinit {
    cancelable?.cancel()
  }
  
  // MARK: - Coordinator Methods
  func performWithoutObservation(_ block: () -> Void) {
    ignoreNotifications = true
    block()
    ignoreNotifications = false
  }
  
  private func notify(for event: Event) {
    guard !ignoreNotifications else { return }
    switch MapEvents.EventKind(rawValue: event.type) {
      case .cameraChanged:
        camera.center = mapView.cameraState.center
        camera.zoom = mapView.cameraState.zoom
      default:
        break
    }
  }
}

// MARK: - Camera
struct Camera {
  var center: CLLocationCoordinate2D
  var zoom: CGFloat
}

