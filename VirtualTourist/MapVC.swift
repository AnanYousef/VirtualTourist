//
//  MapVC.swift
//  VirtualTourist
//
//  Created by Anan Yousef on 27/01/2021.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    
    var pins: [Pin] = []
    var dataController: DataController!
    
    override func viewWillAppear(_ animated: Bool) {
        addAnnotations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            mapView.removeAnnotations(mapView.annotations)
            addAnnotations()
        }
        
    }
    
    @objc func handleTap(gestureReconizer: UIGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.lat = coordinate.latitude.magnitude
            pin.lon = coordinate.longitude.magnitude
            do {
                try dataController.viewContext.save()
            }catch{
                print("error")
            }
            pins.append(pin)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func addAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            
            
            let lat = CLLocationDegrees(pin.lat)
            let long = CLLocationDegrees(pin.lon)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumVC") as? AlbumVC
        controller?.coordinate = view.annotation?.coordinate
        
        for pin in pins {
            if pin.lat.isEqual(to: view.annotation?.coordinate.latitude.magnitude ?? 90){
                controller?.pin = pin
            }
        }
        controller?.dataController = dataController
        self.show(controller!, sender: nil)
    }
    
    


}

