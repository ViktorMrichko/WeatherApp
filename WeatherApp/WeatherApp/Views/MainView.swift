//
//  MainView.swift
//  WeatherApp
//
//  Created by Viktor Mrichko on 19.06.2025.
//

import SwiftUI

struct MainView: View {
    @State private var viewModel = MainViewModel()
    @State private var isSearchDialogShown = false
    @State private var searchCityText = ""
    
    var body: some View {
        ZStack {
            weatherTabs
            
            if isSearchDialogShown {
                searchBar
            }
            
            searchCityButton
        }
        .onAppear(perform: viewModel.getInitialWeatherData)
        .alert("Error", isPresented: $viewModel.isPresentedAlert) {
            Button("OK") {
                viewModel.isPresentedAlert = false
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private extension MainView {
    var searchCityButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isSearchDialogShown
                    = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.black)
                }
            }
            Spacer()
        }
        .padding()
    }
    
    var weatherTabs: some View {
        TabView {
            ForEach(viewModel.weatherData, id: \.self) { weather in
                WeatherCellView(weather: weather,
                                cityName: viewModel.cityName)
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
        VStack {
            TextField("Type city name ...", text: $searchCityText)
                .padding()
                .background(Color.white.cornerRadius(10))
                .frame(width: 250)
                .onChange(of: searchCityText) { _, _ in
                    searchCityText = checkCityNameFormat(for: searchCityText)
                }
            
            HStack {
                confirmButton
                cancelButton
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 25)
                .frame(width: 300, height: 150)
                .foregroundColor(.gray.opacity(0.6))
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
            isSearchDialogShown = false
        } label: {
            configureSearchSectionButtonLabel(for: "Cancel")
        }
    }
    
    func checkCityNameFormat(for cityName: String) -> String {
        return cityName.filter { $0.isLetter }
    }
    
    func cityDidChange() {
        if searchCityText.isEmpty {
            configureTextFieldAlert("Please enter a city name")
        } else if viewModel.cityName == searchCityText {
            configureTextFieldAlert("You are already in this city")
        } else {
            viewModel.getWeatherForecast(for: searchCityText)
            isSearchDialogShown = false
            searchCityText = ""
        }
    }
    
    func configureTextFieldAlert(_ message: String) {
        viewModel.errorMessage = message
        viewModel.isPresentedAlert = true
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
