//
//  Scanningperipherals.swift
//  GoodBLEExample
//
//  Created by Sam Meech-Ward on 2023-08-12.
//

import AsyncCoreBluetooth
import CoreBluetooth
import SwiftUI

struct SavedPeripherals: View {
  var centralManager: CentralManager
  @MainActor @State private var peripherals: [Peripheral] = []

  var body: some View {
    VStack {
      List(peripherals, id: \.state.identifier) { peripheral in
        Section {
          PeripheralListRow(centralManager: centralManager, peripheral: peripheral)
        }
      }
    }
    .navigationTitle("My Devices")
    .task {
      let savedUUIDs = Storage.getSavedDevices()
      let savedPeripherals = await centralManager.retrievePeripherals(withIdentifiers: savedUUIDs)

      peripherals = savedPeripherals

      // Maybe we want to immediatly try to connect to all saved devices
      for peripheral in savedPeripherals {
        do {
          try await centralManager.connect(peripheral)
        } catch {
          // already connected
          print("error trying to connect to peripheral")
        }
      }
    }
  }
}

import CoreBluetoothMock

#Preview {
  MockPeripheral.setupFakePeripherals()
  return SavedPeripherals(centralManager: CentralManager(forceMock: true))
}
