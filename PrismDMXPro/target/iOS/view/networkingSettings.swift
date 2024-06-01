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
        ZStack {
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
                        //JSON Data Export
                        /*
                        LazyHStack {
                            Button("Copy Fixtures") {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = PacketJSONModule(currentPacket: $packet).encode($packet.fixtures.fixtures.wrappedValue) ?? "error"
                            }
                            Button("Copy FixtureGroups") {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = PacketJSONModule(currentPacket: $packet).encode($packet.fixtureGroups.fixtureGroups.wrappedValue) ?? "error"
                            }
                            Button("Copy Templates") {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = PacketJSONModule(currentPacket: $packet).encode($packet.fixtureTemplates.templates.wrappedValue) ?? "error"
                            }
                            Button("Copy Mixer") {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = PacketJSONModule(currentPacket: $packet).encode($packet.mixer.wrappedValue) ?? "error"
                            }
                            Button("Copy Meta") {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = PacketJSONModule(currentPacket: $packet).encode($packet.meta.wrappedValue) ?? "error"
                            }
                        }*/
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
        .background {
            GeometryReader { geo in
                Image("bgImage1")
                    //.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
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
    NWSettingsView(clientData: .constant(ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: true, step: 1), meta: ClientMeta(displayMode: .left))), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: [FixtureTemplate(internalID: "1", name: "Hello", channels: [Channel(internalID: "1", ChannelName: "Milan", ChannelType: "Milan", dmxChannel: "1"), Channel(internalID: "2", ChannelName: "Johannes", ChannelType: "Johannes", dmxChannel: "2")]), FixtureTemplate(internalID: "2", name: "Hugo", channels: [])]), fixtures: FixtureList(fixtures: [Fixture(internalID: "1", name: "Thorsten", startChannel: "1", selected: "false", channels: [Channel(internalID: "3982", ChannelName: "Henriette", ChannelType: "Master", dmxChannel: "39")]), Fixture(internalID: "2", name: "Hans", startChannel: "1", selected: "true", channels: [])]), fixtureGroups: FixtureGroupList(fixtureGroups: [FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"), FixtureGroup(name: "Jürgen", groupID: "2", internalIDs: [], selected: "true")]), mixer: Mixer(pages: [MixerPage(num: "1", faders: [MixerFader(name: "Herbert", color: "#ffffff", isTouched: "false", value: "255", assignedType: "Fixture", assignedID: "1", id: "1")], buttons: [MixerButton(name: "Karsten", color: "#ffffff", isPressed: "true", assignedType: "FixtureGroup", assignedID: "1", id: "2")], id: "3")], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false"))), websocket: .constant(WebSocket(cnw: .constant(ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false)), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false"))))))
}
