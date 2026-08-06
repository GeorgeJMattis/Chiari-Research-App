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
    /// Every ISO country/territory, localized to English, with the United
    /// States pinned first and "Other" last. "Other" lets participants outside
    /// the list still enroll.
    static let countries: [String] = {
        let english = Locale(identifier: "en_US")
        let names = Locale.Region.isoRegions
            .filter { $0.subRegions.isEmpty && $0.identifier.count == 2 }
            .compactMap { english.localizedString(forRegionCode: $0.identifier) }
        let rest = Set(names).subtracting([unitedStates]).sorted()
        return [unitedStates] + rest + ["Other"]
    }()

    /// US Census regions, shown when the selected country is the US.
    static let usRegions: [String] = [
        "Northeast", "Midwest", "South", "West"
    ]

    static let unitedStates = "United States"
}
