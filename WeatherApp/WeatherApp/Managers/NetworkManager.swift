//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 19.06.2025.
//

import CoreLocation
import Combine

struct NetworkManager {
    enum NetworkingError: LocalizedError {
        case badURLResponse(url: URL)
        case errorURL
    }
    
    func download(coordinates: CLLocationCoordinate2D) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(coordinates.latitude)&longitude=\(coordinates.longitude)&daily=temperature_2m_max,precipitation_probability_max,temperature_2m_min&forecast_days=16")
        else {
            return Fail(error: NetworkingError.errorURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap({ try handleURLResponse(output: $0, url: url) })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
                  throw NetworkingError.badURLResponse(url: url)
              }
        return output.data
    }
}
