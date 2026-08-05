//
//  Geography.swift
//  Chiari Research App
//
//  Coarse geography options collected at enrollment (and editable in Profile).
//  Deliberately limited to country + US Census region — no finer location.
//  Exact state was intentionally dropped in favor of the 4-region grouping:
//  combined with a rare diagnosis and other baseline fields, state-level detail
//  is a meaningful re-identification risk that region-level detail avoids
//  while still supporting regional analysis.
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

    /// US Census regions, shown when the selected country is the US.
    static let usRegions: [String] = [
        "Northeast", "Midwest", "South", "West"
    ]

    static let unitedStates = "United States"
}
