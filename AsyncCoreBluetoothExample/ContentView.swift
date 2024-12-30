//
//  ContentView.swift
//  AsyncCoreBluetoothExample
//
//  Created by Sam Meech-Ward on 2023-08-21.
//

import AsyncCoreBluetooth
import SwiftUI

struct ContentView: View {
  let centralManager = CentralManager()
  var body: some View {
    NavigationStack {
      VStack {
        switch centralManager.state.bleState {
        case .unknown:
          Text("Unkown")
        case .resetting:
          Text("Resetting")
        case .unsupported:
          Text("Your device does not support Bluetooth")
        case .unauthorized:
          Text("Go into settings and authorize this app to use Bluetooth")
        case .poweredOff:
          Text("Turn your device's Bluetooth on")
        case .poweredOn:
          VStack(alignment: .leading, spacing: 40) {
            Text("Ready to go")
            NavigationLink {
              ScanningPeripherals(centralManager: centralManager)
            } label: {
              Label("Scan For New Devices", systemImage: "plus")
            }
            NavigationLink {
              SavedPeripherals(centralManager: centralManager)
            } label: {
              Label("View Saved Devices", systemImage: "iphone.gen2.radiowaves.left.and.right.circle")
            }
          }
        }
      }
      .padding()
      .navigationTitle("App")
    }
    .task {
      #if targetEnvironment(simulator)
      MockPeripheral.setupFakePeripherals()
      #endif
//      await centralManager.start()
      for await bleState in await centralManager.startStream() {
        switch bleState {
        case .unknown:
          print("Unkown")
        case .resetting:
          print("Resetting")
        case .unsupported:
          print("Unsupported")
        case .unauthorized:
          print("Unauthorized")
        case .poweredOff:
          print("Powered Off")
        case .poweredOn:
          print("Powered On, ready to scan")
        }
      }
    }
  }
}

// import CoreBluetoothMock
//
// #Preview("powered on") {
//  CBMCentralManagerMock.simulateInitialState(.poweredOn)
//  return ContentView(centralManager: CentralManager(forceMock: true))
// }
