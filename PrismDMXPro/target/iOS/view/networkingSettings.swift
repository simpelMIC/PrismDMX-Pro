//
//  firstNetworkSettings.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI
import OmenTextField
import PageView

struct NWSettingsView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    
    @State var selectedProtocol: ClientNWProtocol = .ws
    var body: some View {
        ZStack {
            Image("bgImage1")
            RoundedRectangle(cornerRadius: 25)
                .fill(.thinMaterial)
                .frame(width: 450, height: 250)
            LazyVStack {
                if $clientData.networking.ready.wrappedValue && !$clientData.networking.connected.wrappedValue {
                    LazyVStack {
                        if $clientData.networking.error.wrappedValue == nil {
                            Text("Connecting...")
                            Button("Cancel") {
                                clientData.networking.connected = false
                                clientData.networking.ready = false
                                ClientDataModule().save($clientData.wrappedValue)
                            }
                        } else {
                            Text("Error")
                                .font(.system(size: 30, weight: .semibold))
                            Text("\($clientData.networking.error.wrappedValue ?? "Unknown Error")")
                            Button("Copy Error") {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = $clientData.networking.error.wrappedValue ?? "Unknown Error"
                            }
                            LazyHStack {
                                Button("Back to Settings") {
                                    clientData.networking.connected = false
                                    clientData.networking.ready = false
                                    ClientDataModule().save($clientData.wrappedValue)
                                }
                                .buttonStyle(.bordered)
                                Button("Retry") {
                                    clientData.networking.connected = false
                                    clientData.networking.ready = false
                                    connect()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                } else {
                    LazyVStack {
                        Text("Networking")
                            .font(.system(size: 30, weight: .semibold))
                        Text("IP Address")
                        LazyHStack {
                            Picker("Protocol", selection: $selectedProtocol, content: {
                                ForEach(ClientNWProtocol.allCases, id: \.self) { index in
                                    Text("\(index.rawValue)://")
                                }
                            })
                            .onSubmit {
                                clientData.networking.nwProtocol = selectedProtocol
                                ClientDataModule().save($clientData.wrappedValue)
                            }
                            TextField("IP", text: $clientData.networking.ip)
                            Text(":")
                            TextField("Port", text: $clientData.networking.port)
                            TextField("Path", text: $clientData.networking.path)
                        }
                        Spacer()
                        Button("Connect") {
                            connect()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .frame(width: 450, height: 250)
        }
        .task {
            selectedProtocol = $clientData.networking.nwProtocol.wrappedValue
            if !$clientData.networking.ready.wrappedValue {
                clientData.networking.ready = false
                clientData.networking.connected = false
            } else {
                connect()
            }
        }
    }
    
    func connect() {
        clientData.networking.ready = true
        ClientDataModule().save($clientData.wrappedValue)
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

#Preview {
    NWSettingsView(clientData: .constant(ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: true, step: 1))), packet: .constant(Packet(templates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"))), websocket: .constant(WebSocket(cnw: .constant(ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false)), packet: .constant(Packet(templates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"))))))
}
