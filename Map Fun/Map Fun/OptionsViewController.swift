//
//  OptionsViewController.swift
//  Map Fun
//
//  Created by Crystal Knight on 10/22/21.
//

import UIKit
import SwiftUI

class OptionsViewController: UIViewController {
  // MARK: - Properties
  // Actions
  @IBAction func swiftUIButtonTapped(_ sender: UIButton) {
    presentSwiftUIMap()
  }
  
  // MARK: - View
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Navigation
  func presentSwiftUIMap() {
    let swiftUIMap = SwiftUIMapView()
    let hostingController = UIHostingController(rootView: swiftUIMap)
    hostingController.title = "SwiftUI Map"

    show(hostingController, sender: self)
  }
}
