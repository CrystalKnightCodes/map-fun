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
    mapView.isRecording.toggle()
    mapView.recordRoute()
    setImage()
  }
  
  @IBAction func deleteRouteTapped(_ sender: UIBarButtonItem) {
    mapView.deleteRoute()
  }
  
// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
 func setImage() {
   if mapView.isRecording {
     recordButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
   } else {
     recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
   }
  }
}



