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
    lazy var geoCoder = CLGeocoder()
    let annotation = MKPointAnnotation()
    let locationManager = CLLocationManager()
    var currentWeather = CurrentWeather()
    var forecast: Forecast!
    var forecasts = [Forecast]()
    
    @IBOutlet weak var datenow: UILabel!
    @IBOutlet weak var currentTempnow: UILabel!
    @IBOutlet weak var currentWeathernow: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var mapView:MKMapView!
    @IBOutlet weak var cityName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(FirstViewController.longpress(gestureRecognizer:)))
        
        uilpgr.minimumPressDuration = 2
        
        mapView.addGestureRecognizer(uilpgr)
                if activePlace == -1 {

        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.addAnnotation(annotation)
        mapView.showsUserLocation = true
                    
                } else {
                    
                                // Get the details to display on map
                    
                                if places.count > activePlace {
                    
                                    if let name = places[activePlace]["name"] {
                    
                                        if let lat = places[activePlace]["lat"] {
                    
                                            if let lon = places[activePlace]["lon"] {
                    
                                                if let latitude = Double(lat) {
                    
                                                    if let longitude = Double(lon) {
                    
                                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    
                                                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                    
                                                        self.mapView.setRegion(region, animated: true)
                    
                                                        let annotation = MKPointAnnotation()
                    
                                                        annotation.coordinate = coordinate
                                                        
                                                        annotation.title = name
                                                        
                                                        self.mapView.addAnnotation(annotation)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

    }
    
    
        func longpress(gestureRecognizer: UIGestureRecognizer){
    
            if gestureRecognizer.state == UIGestureRecognizerState.began {
    
                let touchPoint = gestureRecognizer.location(in: self.mapView)
    
                let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
    
                let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
    
                var title = ""
    
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
    
                    if error != nil {
    
                        print(error as Any)
    
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
    
                    let annotation = MKPointAnnotation()
    
                    annotation.coordinate = newCoordinate
    
                    annotation.title = title
    
                    self.mapView.addAnnotation(annotation)
    
                    places.append(["name":title,"lat":newCoordinate.latitude.description,"lon":newCoordinate.longitude.description])
                    print(places)
                    
                    UserDefaults.standard.set(places, forKey: "places")
                })
            }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
        locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let latitude =  locations.last
        Location.sharedInstance.latitude = locationManager.location?.coordinate.latitude
        Location.sharedInstance.longitude = locationManager.location?.coordinate.longitude
        currentWeather.downloadWeatherData{
            self.downloadForecastData{
                //setup UI to load downloaded data
                self.updateMainUI()
            }
        }
        if let newLocation = locations.last {
            
            let latitudeString = String(format: "%g\u{00B0}",
                                        newLocation.coordinate.latitude)
            latitudeLabel.text = latitudeString
            let longitudeString = String(format: "%g\u{00B0}",
                                         newLocation.coordinate.longitude)
            longitudeLabel.text = longitudeString
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            // Setting map area' limits
            let latDelta:CLLocationDegrees = 0.01
            let lonDelta:CLLocationDegrees = 0.01
            //creating the "square" that will be applied to the region
            //This is the object that defines the area that the map will display
            //Basically, the map will be centered in this area
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
            
            self.mapView.setRegion(region, animated: true)
            
            //CLLocation needed to get the address using reverseGeocodeLocation
            let location = CLLocation(latitude:newLocation.coordinate.latitude,longitude: newLocation.coordinate.longitude)
                        geoCoder.reverseGeocodeLocation(location)
                        {
                            (placemarks, error) -> Void in
                            let placeArray = placemarks as [CLPlacemark]!
                            if(placeArray != nil){
                                // Place details
                                var placeMark: CLPlacemark!
                                placeMark = placeArray?[0]
                                // City
                                if let city = placeMark.addressDictionary!["City"] as? NSString {
                                print(city)
                                      self.cityName.text="This " + "\(city)"
                                }
                                if let country = placeMark.addressDictionary!["Country"] as? NSString {
                                    print(country)
                                }
                            }}
            self.mapView.addAnnotation(annotation)
            
        }}
    
    
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
    
    
    
    
}
