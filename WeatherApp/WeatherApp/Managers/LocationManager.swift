//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 19.06.2025.
//

import CoreLocation
import Combine

final class LocationManager: NSObject {
    let currentLocation = PassthroughSubject<CLLocation, Never>()
    let errorMessage = PassthroughSubject<String?, Never>()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getCityName(from location: CLLocation, completion: @escaping (String?) -> Void) {
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in
            guard let firstPlacemark = placemarks?.first, error == nil else { 
                self.errorMessage.send(error?.localizedDescription)
                completion(nil)
                return
            }
            completion(firstPlacemark.locality)
        }
    }
    
    func getLocation(from cityName: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            if let error = error {
                self.errorMessage.send(error.localizedDescription)
                completion(nil)
                return
            }

            if let coordinate = placemarks?.first?.location?.coordinate {
                completion(coordinate)
            } else {
                completion(nil)
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .restricted, .denied:
            locationManager.requestWhenInUseAuthorization()
            errorMessage.send("Location services are disabled")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage.send(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            errorMessage.send("Unable to determine location")
            return
        }
        
        currentLocation.send(location)
    }
}

