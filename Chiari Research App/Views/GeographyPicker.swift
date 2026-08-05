//
//  GeographyPicker.swift
//  Chiari Research App
//
//  Reusable country + region input, shared by the enrollment flow (WelcomeView)
//  and ProfileView. When the country is the US, the region field becomes a
//  picker of the 4 US Census regions (not individual states — see
//  Geography.swift); otherwise it is free text.
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

        // Region
        if country == Geography.unitedStates {
            Menu {
                ForEach(Geography.usRegions, id: \.self) { r in
                    Button(r) { stateRegion = r }
                }
            } label: {
                HStack {
                    Text("Region")
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
                Text("Region")
                Spacer()
                TextField("Optional", text: $stateRegion)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
