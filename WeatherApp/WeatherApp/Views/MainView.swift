//
//  MainView.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 19.06.2025.
//

import SwiftUI

struct MainView: View {
    @State private var mainViewModel = MainViewModel()
    @State private var isChangeCityViewShown = false
    @State private var textFieldText = ""
    
    var body: some View {
        ZStack {
            weatherSection
            
            if isChangeCityViewShown {
                searchBar
            }
        }
        .onAppear(perform: mainViewModel.getLocationAndFetchWeatherData)
        .alert("Error", isPresented: $mainViewModel.isPresentedAlert) {
            Button("OK") {
                mainViewModel.isPresentedAlert = false
            }
        } message: {
            Text(mainViewModel.errorMessage ?? "")
        }
    }
}

private extension MainView {
    var weatherSection: some View {
        TabView {
            ForEach(mainViewModel.weatherData, id: \.self) { weather in
                WeatherCellView(isChangeCityAlertShown: $isChangeCityViewShown, weather: weather, cityName: mainViewModel.cityName)
            }
        }
        .tabViewStyle(.page)
        .background(
            Image("clouds")
                .resizable()
                .scaledToFill()
        )
        .ignoresSafeArea()
    }
    
    var searchBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(width: 300, height: 150)
                .foregroundColor(.gray.opacity(0.6))
            
            VStack {
                TextField("Type city name ...", text: $textFieldText)
                    .padding()
                    .background(Color.white.cornerRadius(10))
                    .frame(width: 250)
                
                HStack {
                    confirmButton
                    
                    cancelButton
                }
            }
        }
    }
    
    var confirmButton: some View {
        Button {
            cityDidChange()
        } label: {
            configureSearchSectionButtonLabel(for: "OK")
        }
    }
    
    var cancelButton: some View {
        Button {
            isChangeCityViewShown = false
        } label: {
            configureSearchSectionButtonLabel(for: "Cancel")
        }
    }
    
    func cityDidChange() {
        if textFieldText.isEmpty {
            configureTextFieldAlert("Please enter a city name")
        } else if mainViewModel.cityName == textFieldText {
            configureTextFieldAlert("You are already in this city")
        } else {
            mainViewModel.cityName = textFieldText
            mainViewModel.getWeatherForecast(for: mainViewModel.cityName)
            isChangeCityViewShown = false
            textFieldText = ""
        }
    }
    
    func configureTextFieldAlert(_ message: String) {
        mainViewModel.errorMessage = message
        mainViewModel.isPresentedAlert = true
    }
    
    func configureSearchSectionButtonLabel(for buttonName: String) -> some View {
        Text(buttonName)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding()
            .frame(width: 120)
            .background(
                Color.blue
                    .cornerRadius(10)
                    .shadow(radius: 10)
            )
    }
}

#Preview {
    MainView()
}
