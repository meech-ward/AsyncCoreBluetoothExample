//
//  PeripheralListRow.swift
//  AsyncCoreBluetoothExample
//
//  Created by Sam Meech-Ward on 2023-08-23.
//

import AsyncCoreBluetooth
import CoreBluetooth
import SwiftUI

struct PeripheralListRow: View {
  var centralManager: CentralManager
  var peripheral: Peripheral
  
  @State var connectButtonDisabled = false
  @State var disconnectButtonDisabled = true

  private func saveDevice() {
    // Pick a time that makes sense to store the device's uuid for quicker and eaiser connection in the futer
    Storage.saveDevice(uuid: peripheral.state.identifier)
  }

  private func connect() async {
    do {
      // optionally you can call connect with using the returned state async stream
      // if we want to listen to connection change events here, but we're already doing this in the view's initial task
      // let connectionStates = try await centralManager.connect(peripheral)
      try await centralManager.connect(
        peripheral,
        options: [CBConnectPeripheralOptionEnableAutoReconnect: true]
      )

    } catch {
      // happens when the device is already connected or connecting
      print("error trying to connect \(error)")
    }
  }

  private func disconnect() async {
    do {
      // optionally you can use the returned state stream here to get connection state updates
      // but we're ignoring it here because we already get those updates from connect()
      try await centralManager.cancelPeripheralConnection(peripheral)
    } catch {
      // happens when the device is already disconnected
      print("error canceling connection\(error)")
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text("\(peripheral.state.name ?? "No Name")")
      Text(peripheral.state.identifier.uuidString)

      Button("Connect") {
        Task {
          await connect()
        }
      }.disabled(connectButtonDisabled)

      // why does this button get tapped when i tap the view devices link
      // this whole thing is selectable
      Button("Disconnect") {
        Task {
//          await disconnect()
        }
      }.disabled(disconnectButtonDisabled)

      switch peripheral.state.connectionState {
      case .connecting:
        Text("Connecting ")
      case .disconnected(let error):
        if let error = error {
          Text("Disconnected \(error.localizedDescription)")
        }
      case .connected:
        Text("Connected")
        NavigationLink("View Device") {
          PeripheralView(peripheral: peripheral)
        }
      case .disconnecting:
        Text("Disconnecting")
      case .failedToConnect(let error):
        Text("Failed to connect \(error.localizedDescription)")
      }
    }
    .task {
      print("peripeheral list row start")
      let connectionStates = await centralManager.connectionState(forPeripheral: peripheral)
      for await connectionState in connectionStates {
        switch connectionState {
        case .connected, .connecting:
          connectButtonDisabled = true
          disconnectButtonDisabled = false
          saveDevice()
        case .disconnecting, .disconnected:
          connectButtonDisabled = false
          disconnectButtonDisabled = true
        case .failedToConnect:
          disconnectButtonDisabled = false
          connectButtonDisabled = false
        }
      }
      print("peripeheral list row end")
    }
  }
}

import CoreBluetoothMock

// #Preview {
//  MockPeripheral.setupFakePeripherals()
//  return PeripheralListRow(centralManager: CentralManager(forceMock: true))
// }
