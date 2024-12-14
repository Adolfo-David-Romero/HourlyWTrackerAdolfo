//
//  CitySearchComponentView.swift
//  HourlyWTrackerAdolfo
//
//  Created by David Romero on 2024-12-13.
//

import SwiftUI
import Foundation

struct CitySearchComponentView: View {
    @State private var city: String = ""
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter city name", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.words)
                .disableAutocorrection(true)
            
            Button(action: {
                Task {
                    await viewModel.fetchWeatherForCity(city)
                }
            }) {
                Text("Search")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

#Preview {
    CitySearchComponentView(viewModel: WeatherViewModel())
}
