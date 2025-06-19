//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 19.06.2025.
//

import CoreLocation
import Combine

@Observable
final class LocationManager: NSObject {
    var cityName = "Defining location..."
    var errorDescription: String?
    
    @ObservationIgnored
    let locationManager = CLLocationManager()
    
    @ObservationIgnored
    let currentLocation = PassthroughSubject<CLLocation, Never>()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getCityName(from location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in
            guard let firstPlacemark = placemarks?.first, error == nil else {
                self.errorDescription = error?.localizedDescription
                completion(nil)
                return
            }
            completion(firstPlacemark.locality)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .restricted, .denied:
            locationManager.requestWhenInUseAuthorization()
            errorDescription = "Location services are disabled"
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorDescription = error.localizedDescription
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            errorDescription = "Unable to determine location"
            return
        }
        
        currentLocation.send(location)
        
        getCityName(from: location) { [weak self] cityName in
            guard let self = self, let cityName = cityName else {
                self?.errorDescription = "Unable to determine city"
                return
            }
            
            self.cityName = cityName
        }
    }
}

