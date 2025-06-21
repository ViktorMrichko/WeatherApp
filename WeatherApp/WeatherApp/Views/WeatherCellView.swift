//
//  WeatherCellView.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 20.06.2025.
//

import SwiftUI

struct WeatherCellView: View {
    private let weather: WeatherModel
    private let cityName: String
    
    init(weather: WeatherModel, cityName: String) {
        self.weather = weather
        self.cityName = cityName
    }
    
    var body: some View {
        VStack {
            cityNameSection
            
            date
            
            temperature
            
            weatherIcon
            
            rainProbability
        }
    }
}

private extension WeatherCellView {
    var cityNameSection: some View {
        Text("\(cityName)")
            .font(.system(size: 35, weight: .heavy))
            .padding(.bottom)
    }
    
    var date: some View {
        HStack {
            Text(dayOfWeek(from: weather.time) ?? "")
            Text(formatDate(weather.time) ?? "")
        }
        .font(.system(size: 20, weight: .medium))
    }
    
    var temperature: some View {
        VStack {
            Text("\(weather.temperatureMax)°C")
                .font(.system(size: 75, weight: .bold))
            HStack {
                Text("\(weather.temperatureMax)°C")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.red)
                Text("|")
                Text("\(weather.temperatureMin)°C")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.blue)
            }
        }
        .padding(.bottom)
        
    }
    
    var weatherIcon: some View {
        getWeatherIcon()
            .resizable()
            .frame(width: 150, height: 150)
            .padding(.vertical)
    }
    
    var rainProbability: some View {
        HStack{
            Text("Rain probability: ")
            Text("\(weather.precipitationProbability)%")
                .foregroundStyle(.blue)
        }
        .font(.system(size: 20, weight: .medium))
        .padding(.vertical)
    }
    
    func dayOfWeek(from dateString: String, format: String = "yyyy-MM-dd") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = .current
        
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: date)
    }
    
    func formatDate(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM"
        
        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }
        
        return outputFormatter.string(from: date)
    }
    
    func getWeatherIcon() -> Image {
        weather.precipitationProbability < 50 ? Image("sunIcon") : Image("rainIcon")
    }
}

#Preview {
    WeatherCellView(weather: WeatherModel(time: "2025-06-20", temperatureMax: 25, temperatureMin: 17, precipitationProbability: 44), cityName: "Kyiv")
}
