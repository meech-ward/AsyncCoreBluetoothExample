//
//  Scanningperipherals.swift
//  GoodBLEExample
//
//  Created by Sam Meech-Ward on 2023-08-12.
//

import AsyncCoreBluetooth
import CoreBluetooth
import OrderedCollections
import SwiftUI

struct ScanningPeripherals: View {
  let centralManager: CentralManager
  // scanning may retreive the sam peripheral object twice
  @MainActor @State private var peripherals: OrderedSet<Peripheral> = []

  var body: some View {
    VStack {
      List(peripherals, id: \.state.identifier) { peripheral in
        Section {
          PeripheralListRow(centralManager: centralManager, peripheral: peripheral)
        }
      }
    }
    .navigationTitle("Scanning....")
    .task {
      print("start scanning")
      do {
        let scanningPeripherals = try await centralManager.scanForPeripherals(
          //          withServices: nil
          withServices: [UUIDs.Device.service]
        )
        for await peripheral in scanningPeripherals {
          peripherals.append(peripheral)
        }
      } catch {
        print("error scanning for peripherals \(error)")
      }
      print("end scanning")
    }
  }
}

import CoreBluetoothMock

#Preview {
  MockPeripheral.setupFakePeripherals()
  return ScanningPeripherals(centralManager: CentralManager(forceMock: true))
}
