//
//  Place.swift
//  Test_Task_Curentmap
//
//  Created by mac on 4/17/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Place: NSObject, NSCoding  {
    
    var lat : CLLocationDegrees = 0.0
    var lon : CLLocationDegrees = 0.0
    var datetime: String = ""
    var namelocation : String = ""
    var countryname : String = ""
    var locationDefined : Bool = false
    var temperature : String = ""
    var condition : String = ""
    
    
    func toString() -> String {
        return "Date: \(datetime), Coords: \(lat), \(lon), Location: \(namelocation)"
    }
    
    
    init(lat: CLLocationDegrees, lon: CLLocationDegrees,datetime: String,namelocation  : String, countryname : String, locationDefined : Bool, temperature : String, condition : String) {
        self.datetime = datetime
        self.lat = lat
        self.lon = lon
        self.namelocation = namelocation
        self.countryname = countryname
        self.locationDefined = locationDefined
        self.temperature = temperature
        self.condition = condition
        
        
    }
    
    required init (coder decoder: NSCoder) {
        self.datetime = decoder.decodeObject(forKey: "datetime") as? String ?? ""
        self.lat = decoder.decodeDouble(forKey: "lat")
        self.lon = decoder.decodeDouble(forKey: "lon")
        self.namelocation  = decoder.decodeObject(forKey: "namelocation") as? String ?? ""
        self.countryname = decoder.decodeObject(forKey: "countryname") as? String ?? ""
        self.locationDefined = decoder.decodeBool(forKey: "locationDefined")
        self.temperature = decoder.decodeObject(forKey: "temperature") as? String ?? ""
        self.condition = decoder.decodeObject(forKey: "condition") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(datetime, forKey: "datetime")
        coder.encode(lat, forKey: "lat")
        coder.encode(lon, forKey: "lon")
        coder.encode(namelocation , forKey: "namelocation")
        coder.encode(countryname, forKey: "countryname")
        coder.encode(locationDefined, forKey: "locationDefined")
        coder.encode(temperature, forKey: "temperature")
        coder.encode(condition, forKey: "condition")
    }
}








