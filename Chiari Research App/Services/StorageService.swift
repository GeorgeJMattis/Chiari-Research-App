//
//  StorageService.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/17/26.
//

import Foundation

class StorageService {
    private let encoder = JSONEncoder()
    private let fileManager = FileManager.default

    func savePressureDataToDisk(_ data: [PressureData]) {
        do {
            let encodedData = try encoder.encode(data)
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent("pressure-data.json")

            try encodedData.write(to: fileURL)
        } catch {
            print("Failed to encode pressure data: \(error)")
        }
    }
}
