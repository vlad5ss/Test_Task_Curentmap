//
//  Location.swift
//  Test_Task_Curentmap
//
//  Created by mac on 4/12/17.
//  Copyright © 2017 mac. All rights reserved.
//

import CoreLocation

class Location {
    static var sharedInstance = Location()
    private init(){}
    
    var latitude:Double!
    var longitude: Double!
}
