//
//  WeatherModelDTO.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 19.06.2025.
//

import Foundation

struct WeatherModelDTO: Codable {
    let latitude, longitude: Double
    let units: Units
    let days: Days

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case units = "daily_units"
        case days = "daily"
    }
}

struct Days: Codable {
    let time: [String]
    let temperatureMax: [Double]
    let temperatureMin: [Double]
    let precipitationProbability: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"
        case precipitationProbability = "precipitation_probability_max"
    }
}

struct Units: Codable {
    let time, temperature, precipitationProbability: String

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m_max"
        case precipitationProbability = "precipitation_probability_max"
    }
}
