//
//  StorageService.swift
//  Chiari Research App
//
//  Created by George Mattis on 4/17/26.
//


class StorageService {
    let encoder = JSONEncoder()
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .documentDirectory, in : .userDomainMask)
    let documentsDirectory = urls[0]

    func savePressureDataToDisk(_ data: PressureData) {
        do {
            let encodedData = try encoder.encode(data)
            data.write(to:)
            
        } catch {
            print("Failed to encode pressure data: \(error)")
        }
    }
}