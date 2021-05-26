//
//  CreateNoteViewController.swift
//  sample_design_project
//
//  Created by SatnamSingh on 26/05/21.
//

import UIKit
import MapKit
import CoreData

class CreateNoteViewController: UIViewController ,CLLocationManagerDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var detailField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var crossButtonAudio: UIBarButtonItem!
    @IBOutlet weak var playButtonAudio: UIBarButtonItem!
    @IBOutlet weak var sliderAudio: UISlider!
    @IBOutlet weak var barButtonForSlider: UIBarButtonItem!
    
    //MARK:- MemberVariables
    private var userLocation : CLLocation?
    private var isLocationEnabled = false
    private var selectedImage : UIImage?
    var locationManager = CLLocationManager()
    let imagePicker = UIImagePickerController()
    var parentFolder : Folder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        //assigning location delegate
        locationManager.delegate = self
        //for accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //requesting location
        locationManager.requestWhenInUseAuthorization()
        //start location update
        locationManager.startUpdatingLocation()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveData))
        // Do any additional setup after loading the view.
    }
 
    //MARK: - To fetech location
    //this function is called whenever user location is changed
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation  = locations[0]
        
    }
    
    @IBAction func addLocationButton(_ sender: UISwitch) {
        guard userLocation != nil else {
            sender.setOn(false, animated: true)
            let alert = UIAlertController(title: "Error", message: "Location permission not available.\nPlease allow location in settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return }
        isLocationEnabled = !isLocationEnabled
        if isLocationEnabled{
            self.mapView.showsUserLocation = true
            
            //define span
            let latDelta:CLLocationDegrees = 0.1
            let longDelta:CLLocationDegrees = 0.1
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            
            //get location
            let location = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
            
            //define region where we want to display marker
            let region = MKCoordinateRegion(center: location, span: span)
            
            //set region and for smooth animation.
            mapView.setRegion(region, animated: true)
        }else{
            self.mapView.showsUserLocation = false
        }
    }
    
    //MARK: - fetch photo
    //to show action sheet to select camera or gallery
    @IBAction func addPhotoFunction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Error!", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary() {
        print("Inside gallery")
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.selectedImage = info[.originalImage] as? UIImage
        self.imageView.image = self.selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Add audio
    @IBAction func addAudioFunction(_ sender: UIBarButtonItem) {
        
    }
    
    //MARK: - Save Data after validation
    @objc func saveData(){
        guard self.parentFolder != nil else { return }
        if titleField.text == "" || detailField.text == "" {
            let alert = UIAlertController(title: "WARNING!", message: "Data should be filled properly", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let title = titleField.text
        let detail = detailField.text
        var lat : Double = 0
        var long : Double = 0
        if isLocationEnabled{
            lat = userLocation!.coordinate.latitude
            long = userLocation!.coordinate.longitude
        }
        var imageData : Data?
        if selectedImage != nil{
            imageData = selectedImage?.pngData()
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newNote = Note(context: context)
        newNote.title = title
        newNote.detail = detail
        newNote.date = Date()
        newNote.latitude = lat
        newNote.latitude = long
        newNote.image = imageData
        newNote.parentFolder = self.parentFolder
        do {
            try context.save()
        } catch  {
            print(error)
        }
        self.navigationController?.popViewController(animated: true)
    }

    
    
}
