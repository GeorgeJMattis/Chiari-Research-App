//
//  Geography.swift
//  Chiari Research App
//
//  Coarse geography options collected at enrollment (and editable in Profile).
//  Deliberately limited to country + state/region — no finer location.
//

import Foundation

enum Geography {
    /// A short, ordered list of common study countries. "Other" lets
    /// participants outside the list still enroll.
    static let countries: [String] = [
        "United States",
        "Canada",
        "United Kingdom",
        "Ireland",
        "Australia",
        "New Zealand",
        "Germany",
        "France",
        "Netherlands",
        "Spain",
        "Italy",
        "India",
        "Other"
    ]

    /// US states/territories, shown when the selected country is the US.
    static let usStates: [String] = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia",
        "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
        "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
        "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
        "New Hampshire", "New Jersey", "New Mexico", "New York",
        "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
        "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
        "West Virginia", "Wisconsin", "Wyoming"
    ]

    static let unitedStates = "United States"
}
