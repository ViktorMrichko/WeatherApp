//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 19.06.2025.
//

import Foundation
import Combine

@Observable
class MainViewModel {
    var weather: [WeatherModel] = []
    var errorMessage: String?
    
    private let networkManager: NetworkManager
    private let locationManager: LocationManager
    private var cancellables: Set<AnyCancellable> = []
    
    init(networkManager: NetworkManager, locationManager: LocationManager) {
        self.networkManager = networkManager
        self.locationManager = locationManager
    }
    
    func getLocationAndFetchWeatherData() {
        locationManager.currentLocation
            .first()
            .sink { coordinates in
                self.fetchWeatherData(latitude: coordinates.coordinate.latitude,
                                      longitude: coordinates.coordinate.longitude)
            }
            .store(in: &cancellables)
    }
    
    private func fetchWeatherData(latitude: Double, longitude: Double) {
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=temperature_2m_max,precipitation_probability_max&forecast_days=16")
        else {
            return
        }
        
        networkManager.download(url: url)
            .decode(type: WeatherModelDTO.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] weatherDTO in
                guard let self else { return }
                weatherModelDTOToWeatherModel(weatherDTO)
            })
            .store(in: &cancellables)
    }
    
    private func weatherModelDTOToWeatherModel(_ weatherModelDTO: WeatherModelDTO) {
        let count = min(
            weatherModelDTO.days.time.count,
            weatherModelDTO.days.temperature.count,
            weatherModelDTO.days.precipitationProbability.count
        )

        for i in 0..<count {
            let model = WeatherModel(
                time: weatherModelDTO.days.time[i],
                temperature: Int(weatherModelDTO.days.temperature[i]),
                precipitationProbability: weatherModelDTO.days.precipitationProbability[i]
            )
            self.weather.append(model)
        }
    }
}
