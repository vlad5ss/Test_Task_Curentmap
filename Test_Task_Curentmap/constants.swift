

import Foundation


let BASE_URL = "http://api.openweathermap.org/data/2.5/weather?"
let LATITUDE = "lat="
let LONGITUDE = "&lon="
let APP_ID = "&appid="
let API_KEY = "09403ddd9e2a0be1e8bfbf7a0c4b84e4"

let CURRENT_WEATHER_URL = "\(BASE_URL)\(LATITUDE)\(Location.sharedInstance.latitude!)\(LONGITUDE)\(Location.sharedInstance.longitude!)\(APP_ID)\(API_KEY)"

let BASE_FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast/daily?"
let COUNT_FORMAT = "&cnt=7&mode=json"

let FORECAST_URL = "\(BASE_FORECAST_URL)\(LATITUDE)\(Location.sharedInstance.latitude!)\(LONGITUDE)\(Location.sharedInstance.longitude!)\(COUNT_FORMAT)\(APP_ID)\(API_KEY)"

typealias DownloadComplete = () -> ()
