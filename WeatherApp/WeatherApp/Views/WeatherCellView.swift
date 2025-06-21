//
//  WeatherCellView.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 20.06.2025.
//

import SwiftUI

struct WeatherCellView: View {
    @Binding var isChangeCityAlertShown: Bool
    private let weather: WeatherModel
    private let cityName: String
    
    init(isChangeCityAlertShown: Binding<Bool>, weather: WeatherModel, cityName: String) {
        self._isChangeCityAlertShown = isChangeCityAlertShown
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
        HStack {
            Text("\(cityName)")
                .font(.system(size: 35, weight: .heavy))
            
            Button {
                isChangeCityAlertShown = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.black)
            }
        }
    }
    
    var date: some View {
        HStack {
            Text(dayOfWeek(from: weather.time) ?? "")
            Text(formatDate(weather.time) ?? "")
        }
    }
    
    var rainProbability: some View {
        Text("Rain probability: \(weather.precipitationProbability)%")
    }
    
    var temperature: some View {
        HStack {
            Text("\(weather.temperatureMax)°C")
                .foregroundStyle(.red)
            Text("|")
            Text("\(weather.temperatureMin)°C")
                .foregroundStyle(.blue)
        }
    }
    
    var weatherIcon: some View {
        getWeatherIcon()
            .resizable()
            .frame(width: 150, height: 150)
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
    WeatherCellView(isChangeCityAlertShown: .constant(true), weather: WeatherModel(time: "2025-06-20", temperatureMax: 25, temperatureMin: 17, precipitationProbability: 44), cityName: "Kyiv")
}
