//
//  firstNetworkSettings.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI

struct NWSettingsView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    @State var selectedProtocol: ClientNWProtocol = .ws
    var body: some View {
        NavigationStack {
            if $clientData.networking.error.wrappedValue == nil {
                List {
                    Picker("Protocol", selection: $selectedProtocol) {
                        ForEach(ClientNWProtocol.allCases, id: \.self) { protocolCase in
                            Text(protocolCase.rawValue).tag(protocolCase)
                        }
                    }
                    TextField("IP", text: $clientData.networking.ip)
                    TextField("Port", text: $clientData.networking.port)
                    TextField("Path", text: $clientData.networking.path)
                    Button("Connect") {
                        connect()
                        clientData.networking.ready = true
                        ClientDataModule().save($clientData.wrappedValue)
                    }
                }
                .navigationTitle("Network Settings")
                .toolbar {
                    Text("Error: \($clientData.networking.error.wrappedValue ?? "nil")")
                    Text("Connected: \(String($clientData.networking.connected.wrappedValue))")
                }
            } else {
                List {
                    Text($clientData.networking.error.wrappedValue ?? "Unexpected Error")
                    Button("Go to settings") {
                        clientData.networking.ready = false
                        clientData.networking.error = nil
                        disconnect()
                    }
                }
            }
        }
        .task {
            if clientData.networking.ready {
                connect()
            }
        }
    }
    
    func connect() {
        Task {
            await websocket.connect(cprotocol: selectedProtocol, ip: $clientData.networking.ip.wrappedValue, port: $clientData.networking.port.wrappedValue, path: $clientData.networking.path.wrappedValue)
        }
        ClientDataModule().save($clientData.wrappedValue)
    }
    
    func disconnect() {
        Task {
            await websocket.disconnect(response: true)
        }
    }
}

struct NWErrorView: View {
    @State var error: String
    var body: some View {
        Text(error)
    }
}
