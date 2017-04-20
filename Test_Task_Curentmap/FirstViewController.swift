//
//  FirstViewController.swift
//  Test_Task_Curentmap
//
//  Created by mac on 4/13/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire

class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var userPinView: MKAnnotationView!
    let locationManager = CLLocationManager()
    var currentWeather = CurrentWeather()
    var forecast: Forecast!
    var forecasts = [Forecast]()
    var place: Place?
    var places: [Place]!
    
    @IBOutlet weak var datenow: UILabel!
    @IBOutlet weak var currentTempnow: UILabel!
    @IBOutlet weak var currentWeathernow: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var mapView:MKMapView!
    @IBOutlet weak var cityName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let place = place {
            load(place: place)
        } else {
            print("not load")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    }
    
    @IBAction func SaveLocationButton(_ sender: Any) {
 
    }
    
    private func locationManager(_ manager: CLLocationManager,
                                 didFailWithError error: NSError) {
        let errorType = error.code == CLError.denied.rawValue
            ? "Access Denied": "Error \(error.code)"
        let alertController = UIAlertController(title: "Location Manager Error",
                                                message: errorType, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel,
                                     handler: { action in })
        alertController.addAction(okAction)
        present(alertController, animated: true,
                completion: nil)
    }
    
    func load(place: Place) {
        print("func not load")
        let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
        getPlace(coordinate: coordinate ) {
            (place) in
            self.places.append(place)
            Place.save(places: self.places)
        }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = place.name
        self.mapView.addAnnotation(annotation)
    }
    
    
    func createAnnotation(title: String, coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        self.mapView.addAnnotation(annotation)
    }
    
    
    func getPlace(coordinate: CLLocationCoordinate2D, completionHandler: @escaping (_ place: Place) -> Void) {
        
        let location = CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude)
        
        print(coordinate.latitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) in
            var title = ""
            if let error = error {
                print(error)
            } else {
                if let placemark = placemarks?[0] {
                    if placemark.subThoroughfare != nil {
                        title += placemark.subThoroughfare! + " "
                    }
                    if placemark.thoroughfare != nil {
                        title += placemark.thoroughfare!
                    }
                }
            }
            
            if title == "" {
                title = "Added \(NSDate())"
            }
            print(title)
            self.createAnnotation(title: title, coordinate: coordinate)
            let newPlace = Place(name: title, lat: coordinate.latitude,
                                 lon: coordinate.longitude)
            completionHandler(newPlace)
        })
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
        locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        Location.sharedInstance.latitude = locationManager.location?.coordinate.latitude
        Location.sharedInstance.longitude = locationManager.location?.coordinate.longitude
        currentWeather.downloadWeatherData{
            self.downloadForecastData{
                self.updateMainUI()
            }
        }
        let location = locations[0]
        self.latitudeLabel.text = String(location.coordinate.latitude)
        self.longitudeLabel.text = String(location.coordinate.longitude)

            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let latDelta:CLLocationDegrees = 0.01
            let lonDelta:CLLocationDegrees = 0.01
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        self.mapView.setRegion(region, animated: true)
                    let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

                    CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
        
                if error != nil {
        
                    print(error)
        
                } else {
        
                    if let placemark = placemarks?[0] {
        
                        var address = ""
        
                        if placemark.subThoroughfare != nil {
        
                            address += placemark.subThoroughfare! + " "
        
                        }
        
                        if placemark.thoroughfare != nil {
        
                            address += placemark.thoroughfare! + " "
        
                        }
        
                        if placemark.subLocality != nil {
        
                            address += placemark.subLocality! + " "
        
                        }
        
                        if placemark.subAdministrativeArea != nil {
        
                            address += placemark.subAdministrativeArea! + "\n "
        
                        }
        
                        if placemark.postalCode != nil {
        
                            address += placemark.postalCode! + " "
                            
                        }
                        
                        if placemark.country != nil {
                            
                            address += placemark.country! + " "
                            
                        }
                        print(address)
                        self.cityName.text = address
                        self.createAnnotation(title: address, coordinate:  location.coordinate)
//                                    let newPlace = Place(name: title!, lat: coordinate.latitude,
//                                                         lon: coordinate.longitude)
                    }
                    
                }
                
            }
            self.mapView.setRegion(region, animated: true)
//            self.mapView.addAnnotation(annotation)
        }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse:
            print("Authorization Granted")
            break
        case .denied:
            // User denied your app access to Location Services, but can grant access from Settings.app
            print("Authorization Denied")
            break
        default:
            // Nothing happens
            break
        }
        
    }

  
    
    
    func downloadForecastData(completed: @escaping DownloadComplete){
        //Downloading forecast weather data for Tableview
        let forecastURL = URL(string: FORECAST_URL)!
        Alamofire.request(forecastURL).responseJSON{
            response in
            let result = response.result
            if let dictionary = result.value as? Dictionary<String, AnyObject> {
                if let list = dictionary["list"] as? [Dictionary<String, AnyObject>] {
                    for obj in list {
                        let forecast = Forecast(weatherDictionary: obj)
                        self.forecasts.append(forecast)
                    }
                    self.forecasts.remove(at: 0)
                }
            }
            completed()
        }
    }
    
    func updateMainUI(){
        datenow.text = currentWeather.date
        currentTempnow.text = "\(currentWeather.currentTemp)"
        currentWeathernow.text = currentWeather.weatherType
    }
    
    
//    / Saves the timestamp of when the user has made a change to the NSUserDefaults
//    func saveTimestamp() {
//        let prefs = UserDefaults.standard
//        let timestamp = Date()
//        prefs.set(timestamp, forKey: ViewController.lastUpdate)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = DateFormatter.Style.long
//        dateFormatter.timeStyle = .medium
//        lastUpdateText.text = "Last Update:" + dateFormatter.string(from: timestamp)
//    }
//    
//    // Updates the view with the user values already stored in NSUserDefaults
//    func getUserPreferences() {
//        let prefs = UserDefaults.standard
//        
//        // Get Favorite beer
//        if let beer = prefs.string(forKey: ViewController.favoriteBeer) {
//            favoriteBeerEdit.text = beer
//        }
//        
//        // Get profile image
//        if let imageData = prefs.object(forKey: ViewController.profileImage) as? Data {
//            let storedImage = UIImage.init(data: imageData)
//            profileImage.image = storedImage
//        }
//        
//        // Get the last time something was stored
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = DateFormatter.Style.long
//        dateFormatter.timeStyle = .medium
//        if let lastUpdateStored = (prefs.object(forKey: ViewController.lastUpdate) as? Date) {
//            lastUpdateText.text = "Last Update:" + dateFormatter.string(from: lastUpdateStored)
//        } else {
//            lastUpdateText.text = "Last Update: Never"
//        }
//    }

    
    
}
