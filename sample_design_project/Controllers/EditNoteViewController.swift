//
//  EditNoteViewController.swift
//  sample_design_project
//
//  Created by SatnamSingh on 26/05/21.
//

import UIKit
import CoreData
import MapKit

class EditNoteViewController: UIViewController ,CLLocationManagerDelegate,MKMapViewDelegate{
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailField: UITextView!
    @IBOutlet weak var spaceOnToolBar: UIBarButtonItem!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    
    var note:Note?
    var delegate : NotesViewController?
    
    override func viewDidLoad() {
        mapView.delegate = self
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveData))
        fetchNote()
    }
    
    private func fetchNote()  {
        guard let noteFetched = note else { return }
        titleField.text = noteFetched.title
        dateLabel.text = "Created: - \(Date.getDateWithFormat(date: noteFetched.date ?? Date()))"
        detailField.text = noteFetched.detail
        if noteFetched.image == nil {
            imageView.image = UIImage(named: "no_image_found.jpg")
        }else{
            imageView.image = UIImage(data: noteFetched.image!)
        }
        if noteFetched.voice == nil {
            spaceOnToolBar.title = "No Audio in note"
            playButton.isEnabled = false
            stopButton.isEnabled = false
        }else{
        
        }
 
        if noteFetched.latitude == 0 && noteFetched.longitude == 0 {
            
        }else{
            setLocationOnMap(note: noteFetched)
        }
    }
    
    func setLocationOnMap(note:Note)  {
        //define span
        let latDelta:CLLocationDegrees = 0.05
        let longDelta:CLLocationDegrees = 0.05
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        //get location
        let location = CLLocationCoordinate2D(latitude: note.latitude, longitude: note.longitude)
        
        //define region where we want to display marker
        let region = MKCoordinateRegion(center: location, span: span)
        
        //set region and for smooth animation.
        mapView.setRegion(region, animated: true)
        //adding annotation
        let annotation = MKPointAnnotation()
        annotation.title = "Where Note is created"
        annotation.subtitle = "Created:- \(Date.getDateWithFormat(date: note.date ?? Date()))"
        annotation.coordinate = location
        self.mapView.addAnnotation(annotation)
    }

    @objc func saveData(){
        
    }
    
}

