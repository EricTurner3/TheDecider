//
//  FirstViewController.swift
//  The Decider
//
//  Created by Eric Turner on 2/25/18.
//  Copyright © 2018 Eric Turner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FirstViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {


    @IBOutlet weak var image: UIImageView!
    /* Unused Map View
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
     */
    
    @IBOutlet weak var eatLabel: UILabel!
    @IBOutlet weak var ideasButton: UIButton!
    
    @IBOutlet weak var typePicker: UIPickerView!
    
    //This is the ID of the typePicker
    var foodType = 0;
    
    var pickerData = ["Fast Food", "Restaurant"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        typePicker.dataSource = self
        typePicker.delegate = self
        
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
    }
    /* Unused Map
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        determineCurrentLocation()
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        locationManager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        map.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        map.addAnnotation(myAnnotation)
    }
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        // Row count: rows equals array length.
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        // Return a string from the array for this row.
        return pickerData[row]
    }


    @IBAction func ideasClick(_ sender: Any) {
        labelAnimator(label: eatLabel, text: foodPlace())
       
       //mapSearch(searchString: eatLabel.text!)
        
    }
    @IBAction func navigateClick(_ sender: Any) {
        let query = eatLabel.text;
        
        var newQuery = query?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        launchApp(decodedURL: "http://maps.apple.com/?q=" + newQuery!)
    }
    
    func launchApp(decodedURL: String) {
        let alertPrompt = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    /* Unused Map
    func mapSearch(searchString: String){
        //Grab User's Location Again and Remove all other annotations
        determineCurrentLocation()
        self.map.removeAnnotations(map.annotations)
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchString
        localSearchRequest.region = map.region
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
    
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchString
            self.pointAnnotation.coordinate = (localSearchResponse?.mapItems.first?.placemark.coordinate)!
            self.map.setRegion(localSearchResponse!.boundingRegion, animated: true)
    
    
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.map.centerCoordinate = self.pointAnnotation.coordinate
            self.map.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    */
    func foodPlace() -> String {
        var randomIndex: Int;
        var choice = " ";
        var fastfoodPlaces = ["McDonald's", "Steak N Shake", "Wendy's","Arby's","Subway", "Jimmy Johns", "Rally's", "Chick-fil-A"]
        var restaurantfoodPlaces = ["Logan's Roadhouse", "Bob Evans", "Texas Roadhouse", "O'Charley's", "Wingstop", "Cracker Barrel", "Red Robin"]
        
        //If Fast Food (index 0) is selected
        if(typePicker.selectedRow(inComponent: foodType) == 0){
            randomIndex = Int(arc4random_uniform(UInt32(fastfoodPlaces.count)));
            choice = fastfoodPlaces[randomIndex];
            
            imageAnimator(imageView: self.image, image: UIImage(named:choice)!)
            
        }
        //If Restaurant (index 1) is selected
        else if(typePicker.selectedRow(inComponent: foodType) == 1){
            randomIndex = Int(arc4random_uniform(UInt32(restaurantfoodPlaces.count)));
            choice = restaurantfoodPlaces[randomIndex];
            
            imageAnimator(imageView: self.image, image: UIImage(named:choice)!)
        }
        
        return choice
    }
    
    func imageAnimator(imageView:UIImageView, image:UIImage){
        let imageArray: [UIImage] = [UIImage(named: "McDonald's")!,
                          UIImage(named: "Logan's Roadhouse")!,
                          UIImage(named: "Bob Evans")!,
                          UIImage(named: "Jimmy Johns")!,
                          UIImage(named: "Arby's")!,
                          UIImage(named: "Rally's")!]
        imageView.animationImages = imageArray
        imageView.animationDuration = 0.8
        imageView.animationRepeatCount = 1
        imageView.startAnimating()
        UIView.transition(with: imageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            imageView.image = image
        }, completion: nil)
        
        
    }
    func labelAnimator(label:UILabel, text:String) {
        UIView.transition(with: label, duration: 2, options: .transitionCrossDissolve, animations: {
            label.text = text
        }, completion: nil)
    }
    
}

