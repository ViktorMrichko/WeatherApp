//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 19.06.2025.
//

import Combine
import SwiftUI
import CoreLocation

@Observable
class MainViewModel {
    var weatherData: [WeatherModel] = []
    private(set) var cityName: String = ""
    var errorMessage: String?
    var isPresentedAlert = false 
    
    private let locationManager = LocationManager()
    private let networkManager = NetworkManager()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        getLocationErrors()
    }

    func getInitialWeatherData() {
        locationManager.currentLocation
            .first()
            .sink { location in
                self.fetchWeatherData(for: location.coordinate)
                self.determineCityName(for: location)
            }
            .store(in: &cancellables)
    }
    
    func getWeatherForecast(for cityName: String) {
        locationManager.getLocation(from: cityName) { location in
            guard let location = location else {
                self.errorMessage = "Failed to find city"
                return
            }
            
            self.fetchWeatherData(for: location, and: cityName)
        }
    }
    
    private func determineCityName(for location: CLLocation) {
        self.locationManager.getCityName(from: location, completion: { determinedCityName in
            guard let determinedCityName = determinedCityName else { return }
            self.cityName = determinedCityName
        })
    }
    
    private func getLocationErrors() {
        locationManager.errorMessage
            .sink { error in
                self.errorMessage = error
                self.isPresentedAlert = true
            }
            .store(in: &cancellables)
    }
    
    private func fetchWeatherData(for coordinates: CLLocationCoordinate2D, and cityName: String? = nil) {
        networkManager.downloadWeather(for: coordinates)
            .decode(type: WeatherModelDTO.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] weatherDTO in
                guard let self else { return }
                
                self.weatherData = []
                if let cityName = cityName {
                    self.cityName = cityName
                }
                mapToWeatherModel(from: weatherDTO)
            })
            .store(in: &cancellables)
    }
    
    private func showError(message: String) {
        self.errorMessage = errorMessage
        isPresentedAlert = true
    }
    
    private func mapToWeatherModel(from weatherModelDTO: WeatherModelDTO) {
        let count = min(
            weatherModelDTO.days.time.count,
            weatherModelDTO.days.temperatureMax.count,
            weatherModelDTO.days.temperatureMin.count,
            weatherModelDTO.days.precipitationProbability.count
        )

        for i in 0..<count {
            let model = WeatherModel(
                time: weatherModelDTO.days.time[i],
                temperatureMax: Int(weatherModelDTO.days.temperatureMax[i]),
                temperatureMin: Int(weatherModelDTO.days.temperatureMin[i]),
                precipitationProbability: weatherModelDTO.days.precipitationProbability[i]
            )
            self.weatherData.append(model)
        }
    }
}
