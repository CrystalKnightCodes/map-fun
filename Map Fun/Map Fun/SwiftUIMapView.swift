//
//  SwiftUIMap.swift
//  Map Fun
//
//  Created by Crystal Knight on 10/22/21.
//

import SwiftUI
import UIKit
import MapboxMaps

struct SwiftUIMapView: View {
  // MARK: - Properties
  @State private var mapController = MapController(frame: .zero)
  @State private var camera = Camera(
    center: CLLocationCoordinate2D(latitude: 35, longitude: 35),
    zoom: 15
  )
  
  @State private var showPauseImage = false
  
  // MARK: - View
  // Main
  var body: some View {
    NavigationView {
      content  // Because view is coming from UIKit, it uses the UIKit Navigation Bar
        .navigationBarHidden(true)
        .onDisappear {
          mapController.timer?.invalidate()
        }
    }
  }
  
  // Content
  private var content: some View {
    VStack(alignment: .trailing) {
      map
      
      HStack {
        Spacer()
        
        recordButton
        
        Spacer()
        
        deleteButton
      }
      
      Spacer()
    }
    .padding(.horizontal)
  }
  
  // Subviews
  private var map: some View {
    SwiftUIMap(camera: $camera, controller: $mapController)
      .frame(maxHeight: UIScreen.main.bounds.width)
  }
  
  private var deleteButton: some View {
    Button {
      mapController.deleteRoute()
    } label: {
      Image(systemName: "trash")
        .resizable()
        .frame(maxWidth: 40, maxHeight: 40)
        .foregroundColor(.red)
    }
  }
  
  private var recordButton: some View {
    Button {
      showPauseImage.toggle()
      mapController.isRecording.toggle()
      mapController.recordRoute()
    } label: {
      Image(systemName: showPauseImage ? "pause.circle" : "record.circle")
        .resizable()
        .frame(maxWidth: 50, maxHeight: 50)
    }
  }
}

// MARK: - Preview
struct SwiftUIMap_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIMapView()
      .previewLayout(.device)
      .previewDevice("iPhone 11 Pro Max")
  }
}
