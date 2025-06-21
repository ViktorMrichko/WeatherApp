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
    var cityName: String = ""
    var errorMessage: String?
    var isPresentedAlert = false 
    
    private let locationManager = LocationManager()
    private let networkManager = NetworkManager()
    private var cancellables: Set<AnyCancellable> = []

    func getLocationAndFetchWeatherData() {
        locationManager.currentLocation
            .first()
            .sink { coordinates in
                self.fetchWeatherData(coordinates: coordinates.coordinate)
                self.locationManager.getCityName(from: coordinates, completion: { determinedCityName in
                    guard let determinedCityName = determinedCityName else { return }
                    self.cityName = determinedCityName
                })
            }
            .store(in: &cancellables)
            
        getLocationErrors()
    }
    
    func getWeatherForecast(for cityName: String) {
        locationManager.getLocation(from: cityName) { coordinates in
            guard let coordinates = coordinates else { return }
            self.weatherData = []
            self.fetchWeatherData(coordinates: coordinates)
        }
    }
    
    private func getLocationErrors() {
        locationManager.errorMessage
            .first()
            .sink { error in
                self.errorMessage = error
                self.isPresentedAlert = true
            }
            .store(in: &cancellables)
    }
    

    private func fetchWeatherData(coordinates: CLLocationCoordinate2D) {
        networkManager.download(coordinates: coordinates)
            .decode(type: WeatherModelDTO.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    self.showError(errorMessage: error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] weatherDTO in
                guard let self else { return }
                weatherModelDTOToWeatherModel(weatherDTO)
            })
            .store(in: &cancellables)
    }
    
    private func showError(errorMessage: String) {
        self.errorMessage = errorMessage
        isPresentedAlert = true
    }
    
    private func weatherModelDTOToWeatherModel(_ weatherModelDTO: WeatherModelDTO) {
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
