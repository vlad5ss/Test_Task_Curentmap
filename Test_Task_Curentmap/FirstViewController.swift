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

var request = Place(lat: 0.0, lon: 0.0, datetime: "", namelocation: "", countryname: "", locationDefined: false, temperature: "", condition: "")
var listRequests = [Place] ()
var history = false


class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var userPinView: MKAnnotationView!
    let locationManager = CLLocationManager()
    var date: String!;
    var condition: String!;
    var temperature: Int!;
    var arrayplaces: String = ""
    var dataExists: Bool = true;
    var locationUpdated = false
    
    
    @IBOutlet weak var datenow: UILabel!
    @IBOutlet weak var currentTempnow: UILabel!
    @IBOutlet weak var currentWeathernow: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var mapView:MKMapView!
    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var countryName: UILabel!

    
    
    @IBAction func ClearHistory(_ sender: Any) {
        listRequests.removeAll()
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: listRequests)
        UserDefaults.standard.set(encodedData, forKey: "listRequest")
        
        print("__________________\nElements: ", listRequests.count)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if history {
            printData()
            return
        }
        
        print("not load")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        decodingAndLoading()
    }
    

    
    //    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    //
    //        switch status {
    //        case .authorizedWhenInUse:
    //            print("Authorization Granted")
    //            break
    //        case .denied:
    //            // User denied your app access to Location Services, but can grant access from Settings.app
    //            print("Authorization Denied")
    //            break
    //        default:
    //            // Nothing happens
    //            break
    //        }
    //
    //    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed to \(status.rawValue)")
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            
        default:
            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        let errorType = error._code == CLError.denied.rawValue
            ? "Access Denied": "Error \(error._code)"
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
        let location = locations[0]
        request.lat = location.coordinate.latitude
        request.lon = location.coordinate.longitude
        //        self.latitudeLabel.text = String(location.coordinate.latitude)
        //        self.longitudeLabel.text = String(location.coordinate.longitude)
        let center = CLLocationCoordinate2D(latitude:  request.lat, longitude:  request.lon)
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        self.mapView.setRegion(region, animated: true)
        let coordinate = CLLocationCoordinate2D(latitude: request.lat, longitude:  request.lon)
        ///Reverse Geocoding
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            
            if error != nil {
                
                print(error ?? <#default value#>)
                
            } else {
                if let placemark = placemarks?[0] {
                    request.locationDefined = true
                    var subThoroughfare = ""
                    
                    if placemark.subThoroughfare != nil {
                        
                        subThoroughfare += placemark.subThoroughfare! + " "
                        
                    }
                    
                    var thoroughfare = ""
                    
                    if placemark.thoroughfare != nil {
                        
                        thoroughfare += placemark.thoroughfare! + " "
                        
                    }
                    
                    var subLocality = ""
                    
                    if placemark.subLocality != nil {
                        
                        subLocality += placemark.subLocality! + " "
                        
                    }
                    
                    var subAdministrativeArea = " "
                    
                    if placemark.subAdministrativeArea != nil {
                        
                        subAdministrativeArea += placemark.subAdministrativeArea! + " "
                        //                            self.addressName.text = subAdministrativeArea
                        //                            request.namelocation = placemark.subAdministrativeArea!
                    }
                    var country = ""
                    
                    if placemark.country != nil {
                        
                        country += placemark.country! + " "
                        request.countryname = placemark.country!
                        //                              self.countryName.text = country
                    }
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = request.namelocation
                    self.mapView.addAnnotation(annotation)
                    
                    self.arrayplaces.append(subAdministrativeArea)
                    request.namelocation=subThoroughfare + thoroughfare + subLocality + subAdministrativeArea  + country
                    
                    self.addressName.text = subThoroughfare + thoroughfare + subLocality + subAdministrativeArea  + country
                    self.weatherLoad()
                }
                
            }
            
        }
        self.mapView.setRegion(region, animated: true)
    }
    
    /////Weathera Load https://github.com/arora-72/weather_Apixu
    func weatherLoad() {
        // Signup for a free api key from https://www.apixu.com/ and replace YOUR_API_KEY with you key
        let apiEndPoint: String = "http://api.apixu.com/v1/current.json?key=4c8fc107b2e44baeac8121816172404&q=\(arrayplaces)";
        let formattedUrl: String = apiEndPoint.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!;
        let urlRequest = URLRequest(url: URL(string: formattedUrl)!);
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    
                    if let current = json["current"] as? [String : AnyObject] {
                        
                        if let temp = current["temp_c"] as? Int {
                            self.temperature = temp;
                        }
                        if let condition = current["condition"] as? [String : AnyObject] {
                            self.condition = condition["text"] as! String
                        }
                    }
                    if let location = json["location"] as? [String : AnyObject] {
                        self.date = location["localtime"] as! String
                    }
                    
                    if let _ = json["error"] {
                        self.dataExists = false
                    }
                    DispatchQueue.main.async {
                        if(self.dataExists){
                            request.datetime = self.date
                            request.temperature = self.temperature.description
                            request.condition = self.condition
                            self.currentTempnow.isHidden = false
                            self.currentWeathernow.isHidden = false
                            self.currentTempnow.text = "\(self.temperature.description)°"
                            self.currentWeathernow.text = self.condition
                            self.datenow.text = self.date
                            self.codingAndSaving()
                        }else {
                            self.currentTempnow.isHidden = true
                            self.currentWeathernow.isHidden = true
                            self.dataExists = true
                        }
                    }
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    
    func codingAndSaving () {
        printData()
        
        listRequests.append(request)
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: listRequests)
        
        UserDefaults.standard.set(encodedData, forKey: "listRequest")
    }
    
    func decodingAndLoading () {
        if let data = UserDefaults.standard.data(forKey: "listRequest"),
            let myList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Place] {
            
            listRequests = myList
        }
    }
    
    func printData () {
        latitudeLabel.text = "\(request.lat)"
        longitudeLabel.text = "\(request.lon)"
        addressName.text = "\(request.namelocation)"
        countryName.text = "\(request.countryname)"
        currentTempnow.text = "\(request.temperature)˚C"
        currentWeathernow.text = "\(request.condition)"
        datenow.text = "\(request.datetime)"
    }
    
}
