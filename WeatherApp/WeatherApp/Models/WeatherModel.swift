//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 19.06.2025.
//

import Foundation

struct WeatherModel: Hashable {
    let time: String
    let temperatureMax: Int
    let temperatureMin: Int
    let precipitationProbability: Int
}
