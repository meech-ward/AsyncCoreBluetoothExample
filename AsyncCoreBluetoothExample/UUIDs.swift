//
//  UUIDs.swift
//  GoodBLEExample
//
//  Created by Sam Meech-Ward on 2023-08-12.
//

import Foundation
import CoreBluetooth

//struct UUIDs {
//  enum Device {
//    static let service = CBUUID(string: "FFE0")
//    static let message = UUID(uuidString: "a204a8f0-b16f-4c4e-84d2-59fc3f25962d")!
//    static let deviceName = UUID(uuidString: "c9911d6a-08b3-4744-a877-8df12edb4e5e")!
//  }
//}

struct UUIDs {
  enum Device {
    static let service = CBUUID(string: "5c1b9a0d-b5be-4a40-8f7a-66b36d0a5176")
    static let message = UUID(uuidString: "5c1b9a0d-b5be-4a40-8f7a-66b36d0a5177")!
    static let deviceName = UUID(uuidString: "c9911d6a-08b3-4744-a877-8df12edb4e5e")!
  }
}


