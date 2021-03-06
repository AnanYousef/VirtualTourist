//
//  AlbumVC.swift
//  VirtualTourist
//
//  Created by Anan Yousef on 27/01/2021.
//

import UIKit
import MapKit
import CoreData

class AlbumVC: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    var coordinate: CLLocationCoordinate2D!
    var photos: [Photo]!
    var pin: Pin!
    var dataController: DataController!
    
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        pin.photos = nil
        print(dataController.viewContext.hasChanges)
        try? self.dataController.viewContext.save()
        collectionView.reloadData()
        photos.removeAll()
        
        getPhotos()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let predicate = NSPredicate(format: "pin == %@", pin)
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            photos = result
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        if photos.isEmpty {
            getPhotos()
        }
        
    }
    // MARK:- Get photos from flickr
    func getPhotos(){
        setUIEnabled(false)
        let _ = FlickrAPI.sharedInstance().displayImageFromFlickrBySearch(coordinate) { (photosArray, error) in
            if let error = error {
                let controller = UIAlertController(title: "", message: "\(error.localizedDescription)", preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(controller, animated: true, completion: nil)
                self.setUIEnabled(true)
            }
            for img in photosArray {
                guard let imageUrlString = img[FlickrAPI.FlickrResponseKeys.MediumURL] as? String else {
                    debugPrint("Cannot find key '\(FlickrAPI.FlickrResponseKeys.MediumURL)' in \(img)")
                    self.setUIEnabled(true)
                    return
                }
                
                let imageURL = URL(string: imageUrlString)
                
                guard let imageData = try? Data(contentsOf: imageURL!) else {
                    print("Image does not exist at \(String(describing: imageURL))")
                    self.setUIEnabled(true)
                    return
                }
                
                let photo: Photo  = Photo(context: self.dataController.viewContext)
                photo.uri = imageURL
                photo.rawPhoto = imageData
                photo.pin = self.pin
                try? self.dataController.viewContext.save()
                self.photos.append(photo)
                
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                }
            }
            
            self.setUIEnabled(true)
            performUIUpdatesOnMain {
                self.collectionView.reloadData()
            }
            
        }

    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .blue
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func setUIEnabled(_ enabled: Bool) {
        performUIUpdatesOnMain {
            self.newCollectionButton.isEnabled = enabled
            
            if enabled {
                self.newCollectionButton.alpha = 1.0
                self.activityIndicator.alpha = 0.0
                self.activityIndicator.stopAnimating()
            } else {
                self.newCollectionButton.alpha = 0.5
                self.activityIndicator.alpha = 1.0
                self.activityIndicator.startAnimating()
            }
        }
    }
    
}
