//
//  EditNoteViewController.swift
//  sample_design_project
//
//  Created by SatnamSingh on 26/05/21.
//

import UIKit
import CoreData
import MapKit
import AVFoundation

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
    var player = AVAudioPlayer()
    var fileName: String?
    
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
            loadAudio(path: noteFetched.voice!)
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
        print("got location: \(note.latitude) , \(note.longitude)")
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

    func loadAudio(path:String) {
        fileName = path
        setupPlayer()
    }
    
    @IBAction func playPauseAudio(_ sender: UIBarButtonItem) {
        if player.isPlaying{
            player.pause()
            playButton.image = UIImage(systemName: "play.fill")
        }else{
            player.play()
            playButton.image = UIImage(systemName: "pause.fill")
        }
    }
    
    @IBAction func stopButton(_ sender: UIBarButtonItem) {
        player.stop()
    }
    
        
    @objc func saveData(){
        if titleField.text == "" || detailField.text == "" {
            let alert = UIAlertController(title: "WARNING!", message: "Data should be filled properly", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        note?.title = titleField.text
        note?.detail = detailField.text
        delegate?.loadNotes()
        delegate?.tableView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK: - AUDIO Extension
extension EditNoteViewController: AVAudioRecorderDelegate,AVAudioPlayerDelegate{
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupPlayer() {
        guard  fileName != nil else { return }
        print("file in edit note : - \(fileName ?? "")")
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName ?? "")
        do {
            try player = AVAudioPlayer(contentsOf: audioFilename)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
        } catch {
            print(error)
        }
    }
}
