//
//  CreateNoteViewController.swift
//  sample_design_project
//
//  Created by SatnamSingh on 26/05/21.
//

import UIKit
import MapKit
import CoreData
import AVFoundation

class CreateNoteViewController: UIViewController ,CLLocationManagerDelegate
                                ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    var parentFolder : Folder?
    var delegate : NotesViewController?
    var locationManager = CLLocationManager()
    var isRecoding = false
    var isRecorded = false
    var isPlaying = false
    var hasSetupPlayer = false
    var timer = Timer()
    
    //MARK: - Image member variables
    private var selectedImage : UIImage?
    let imagePicker = UIImagePickerController()
    
    //MARK:- Audio member variables
    var isAudioRecordingGranted: Bool!
    var soundRecorder : AVAudioRecorder!
    var soundPlayer = AVAudioPlayer()
    var fileName = ""
    
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
        
        playButtonAudio.isEnabled = false
        crossButtonAudio.isEnabled = false
        sliderAudio.isEnabled = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveData))
        // Do any additional setup after loading the view.
        checkRecordPermission()
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
        isRecoding = !isRecoding
        isPlaying = false
        hasSetupPlayer = false
        if isRecorded{
            deleteRecording()
            isRecorded = !isRecorded
        }
        if isRecoding{
            sender.image = UIImage(systemName: "stop.fill")
            setupRecorder()
            soundRecorder.record()
        }else{
            self.playButtonAudio.isEnabled = true
            self.crossButtonAudio.isEnabled = true
            self.barButtonForSlider.isEnabled = true
            self.sliderAudio.value = 0
            soundRecorder.stop()
            sender.image = UIImage(systemName: "mic")
            isRecorded = !isRecorded
            
        }
    }
    
    @IBAction func playAudioFunction(_ sender: UIBarButtonItem) {
        if !hasSetupPlayer{
            setupPlayer()
            hasSetupPlayer = true
        }
        print("\(soundPlayer.isPlaying)")
        if soundPlayer.isPlaying {
            soundPlayer.pause()
            sender.image = UIImage(systemName: "play.fill")
            timer.invalidate()
        }else{
            soundPlayer.play()
            sender.image = UIImage(systemName: "pause.fill")
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateSlider(){
        sliderAudio.value = Float(soundPlayer.currentTime)
        if sliderAudio.value == 0{
            playButtonAudio.image = UIImage(systemName: "play.fill")
            isPlaying = !isPlaying
        }
    }
    
    @IBAction func deleteAudioFunction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete", message: "Are You sure to delete the Audio Recording?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in self.deleteRecording()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        newNote.longitude = long
        newNote.image = imageData
        newNote.parentFolder = self.parentFolder
        if fileName != ""{
            newNote.voice = fileName
            print("file name in saved: - \(fileName)")
        }
        do {
            try context.save()
        } catch  {
            print(error)
        }
        delegate?.loadNotes()
        delegate?.tableView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Extension - audio recording
extension CreateNoteViewController : AVAudioRecorderDelegate,AVAudioPlayerDelegate{
    
    //pop-up for audio permissions
    func checkRecordPermission(){
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSession.RecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    //get url of directory where we want to save Audio
    func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted{
            fileName = "\(Int64(Date().timeIntervalSince1970 * 1_000))_audio.m4a"
            let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
            let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless,
                                  AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                                  AVEncoderBitRateKey : 320000,
                                  AVNumberOfChannelsKey : 2,
                                  AVSampleRateKey : 44100.2] as [String : Any]
            
            do {
                soundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting )
                soundRecorder.delegate = self
                soundRecorder.prepareToRecord()
            } catch {
                print(error)
            }
        }
    }
    
    func deleteRecording()  {
        guard fileName != "" else { return }
        let audioUrl = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            timer.invalidate()
            try FileManager.default.removeItem(at: audioUrl)
            fileName = ""
            isPlaying = false
            hasSetupPlayer = false
            self.crossButtonAudio.isEnabled = false
            self.barButtonForSlider.isEnabled = false
            self.playButtonAudio.isEnabled = false
            self.sliderAudio.value = 0
        } catch  {
            print(error)
        }
    }
    
    func setupPlayer() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName )
        do {
            try soundPlayer = AVAudioPlayer(contentsOf: audioFilename)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
            sliderAudio.maximumValue = Float(soundPlayer.duration)
            sliderAudio.value = 0
        } catch {
            print(error)
        }
    }
}
