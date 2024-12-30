//
//  PeripheralView.swift
//  AsyncCoreBluetoothExample
//
//  Created by Sam Meech-Ward on 2023-08-26.
//

import AsyncCoreBluetooth
import CoreBluetooth
import MightFail
import SwiftUI

func characteristicPropertiesToString(_ properties: CBCharacteristicProperties) -> [String] {
  var propertyStrings: [String] = []

  if properties.contains(.broadcast) {
    propertyStrings.append("Broadcast")
  }
  if properties.contains(.read) {
    propertyStrings.append("Read")
  }
  if properties.contains(.writeWithoutResponse) {
    propertyStrings.append("Write Without Response")
  }
  if properties.contains(.write) {
    propertyStrings.append("Write")
  }
  if properties.contains(.notify) {
    propertyStrings.append("Notify")
  }
  if properties.contains(.indicate) {
    propertyStrings.append("Indicate")
  }
  if properties.contains(.authenticatedSignedWrites) {
    propertyStrings.append("Authenticated Signed Writes")
  }
  if properties.contains(.extendedProperties) {
    propertyStrings.append("Extended Properties")
  }
  if #available(iOS 6.0, *) {
    if properties.contains(.notifyEncryptionRequired) {
      propertyStrings.append("Notify Encryption Required")
    }
    if properties.contains(.indicateEncryptionRequired) {
      propertyStrings.append("Indicate Encryption Required")
    }
  }

  return propertyStrings
}

struct CharacteristicView: View {
  var characteristic: Characteristic
  let peripheral: Peripheral
  @State var properties: [String] = []
  var body: some View {
    VStack(spacing: 40) {
      Text("\(peripheral.state.connectionState)")
      Text("characteristic: \(characteristic.state.uuid.uuidString)")
      Text("properties: \(properties.joined(separator: ", "))")
      if let value = characteristic.state.value {
        Text("value: \(String(data: value, encoding: .utf8) ?? "no value")")
      }
      Button("read") {
        Task {
          let (error, data) = await mightFail { try await peripheral.readValue(for: characteristic) }
          guard let data else {
            print("error getting data \(error)")
            return
          }
          if let data {
            let receivedString = String(data: data, encoding: .utf8)
            print("Received: \(receivedString ?? "unknown")")
          }
        }
      }
      Button("write") {
        Task {
          let (error, _, isSuccess) = await mightFail { try await peripheral.writeValueWithResponse("hello".data(using: .utf8)!, for: characteristic)
          }
          guard isSuccess else {
            print("Error writing \(error)")
            return
          }
          print("finished writing")
        }
      }

      Button("write without response") {
        Task {
          await peripheral.writeValueWithoutResponse("hello".data(using: .utf8)!, for: characteristic)

          print("sent")
        }
      }
    }
    .task {
      // characteristic.characteristic
      let properties = await characteristic.properties
      print("properties: \(properties)")
      self.properties = characteristicPropertiesToString(properties)
    }
  }
}

struct ServiceView: View {
  var service: Service
  var peripheral: Peripheral
  var body: some View {
    Text("service: \(service.state.uuid.uuidString)")
    ForEach(service.state.characteristics ?? []) { characteristic in
      NavigationLink {
        CharacteristicView(characteristic: characteristic, peripheral: peripheral)
      } label: {
        Label("  characterisitc: \(characteristic.state.uuid.uuidString)", systemImage: "arrow.right")
      }
    }
  }
}

struct PeripheralView: View {
  var peripheral: Peripheral
  var body: some View {
    VStack {
      Text(peripheral.state.name ?? "No Name")
      List {
        ForEach(peripheral.state.services ?? []) { service in
          ServiceView(service: service, peripheral: peripheral)
        }
      }
    }
    .navigationTitle(peripheral.state.name ?? "No Name")
    .task {
//      await peripheral.discoverServices(nil)
//      await peripheral.discoverServices([
//        CBUUID(string: "FFE0"),
//        CBUUID(string: "FFE1"),
//        CBUUID(string: "FFE2"),
//        CBUUID(string: "FFE3"),
//        CBUUID(string: "FFE4"),
//        CBUUID(string: "FFE5"),
//      ])
      print("discover services")

      let (servicesError, services) = await mightFail { try await peripheral.discoverServices(nil) }
      guard let services else {
        print("error getting services: \(servicesError)")
        return
      }
      for service in services.values {
        let (error, _, success) = await mightFail { try await peripheral.discoverCharacteristics(nil, for: service) }
        if (!success) {
          print("Error getting characteristics: \(error)")
        }
      }
    }
  }
}

// #Preview {
//  PeripheralView()
// }
