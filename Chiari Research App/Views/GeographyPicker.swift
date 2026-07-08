//
//  GeographyPicker.swift
//  Chiari Research App
//
//  Reusable country + state/region input, shared by the enrollment flow
//  (WelcomeView) and ProfileView. When the country is the US, the state field
//  becomes a picker of US states; otherwise it is free text.
//

import SwiftUI

struct GeographyPicker: View {
    @Binding var country: String
    @Binding var stateRegion: String

    var body: some View {
        // Country
        Menu {
            ForEach(Geography.countries, id: \.self) { c in
                Button(c) {
                    if c != country {
                        country = c
                        stateRegion = ""   // reset when country changes
                    }
                }
            }
        } label: {
            HStack {
                Text("Country")
                    .foregroundStyle(.primary)
                Spacer()
                Text(country.isEmpty ? "Select" : country)
                    .foregroundStyle(country.isEmpty ? .secondary : .primary)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        // State / region
        if country == Geography.unitedStates {
            Menu {
                ForEach(Geography.usStates, id: \.self) { s in
                    Button(s) { stateRegion = s }
                }
            } label: {
                HStack {
                    Text("State")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(stateRegion.isEmpty ? "Select" : stateRegion)
                        .foregroundStyle(stateRegion.isEmpty ? .secondary : .primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } else if !country.isEmpty {
            HStack {
                Text("State / Region")
                Spacer()
                TextField("Optional", text: $stateRegion)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
