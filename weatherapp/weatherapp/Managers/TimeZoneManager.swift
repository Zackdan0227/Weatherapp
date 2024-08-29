//
//  TimeZoneManager.swift
//  weatherapp
//
//  Created by Kedan Zha on 8/29/24.
//

import Foundation
import CoreLocation

class TimeZoneManager: ObservableObject {
    func fetchTimeZone(for location: CLLocation, completion: @escaping (TimeZone?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let timeZone = placemarks?.first?.timeZone {
                completion(timeZone)
            } else {
                completion(nil) // Fallback if time zone not found
            }
        }
    }
}
