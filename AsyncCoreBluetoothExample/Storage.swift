//
//  Storage.swift
//  AsyncCoreBluetoothExample
//
//  Created by Sam Meech-Ward on 2023-08-23.
//

import Foundation

struct Storage {
  private static let deviceUUIDsKey = "deviceUUIDs"

  static func saveDevice(uuid: UUID) {
    var savedUUIDs = getSavedDevices()
    guard !savedUUIDs.contains(uuid) else {
      return
    }
    savedUUIDs.append(uuid)
    let uuidStrings = savedUUIDs.map { $0.uuidString }
    UserDefaults.standard.set(uuidStrings, forKey: deviceUUIDsKey)
  }

  static func getSavedDevices() -> [UUID] {
    if let uuidStrings = UserDefaults.standard.array(forKey: deviceUUIDsKey) as? [String] {
      return uuidStrings.compactMap { UUID(uuidString: $0) }
    }
    return []
  }
}
