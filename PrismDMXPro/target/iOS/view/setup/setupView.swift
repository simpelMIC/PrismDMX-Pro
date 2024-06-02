//
//  setupView.swift
//  PrismDMXPro
//
//  Created by Christian on 02.06.24.
//

import Foundation
import SwiftUI

enum NavigationMode {
    case view
    case stack
}

struct SetupView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    
    @State var navigationMode: NavigationMode?
    var body: some View {
        if navigationMode == .view {
            NavigationView {
                UntergeordneteSetupView(clientData: $clientData, packet: $packet, websocket: $websocket)
            }
        } else if navigationMode == .stack {
            NavigationStack {
                UntergeordneteSetupView(clientData: $clientData, packet: $packet, websocket: $websocket)
            }
        } else {
            NavigationView {
                UntergeordneteSetupView(clientData: $clientData, packet: $packet, websocket: $websocket)
            }
        }
    }
}

struct UntergeordneteSetupView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    var body: some View {
        List {
            NavigationLink("Mixer") {
                
            }
            NavigationLink("Fixtures") {
                FixturesSetupView(clientData: $clientData, packet: $packet, websocket: $websocket)
            }
            NavigationLink("iPad Settings") {
                iPadSettingsView(clientData: $clientData, packet: $packet, websocket: $websocket)
            }
            NavigationLink("Change Project") {
                ProjectSelectionView(clientData: $clientData, packet: $packet, websocket: $websocket, disconnectButton: false)
            }
            Button("Disconnect", role: .destructive) {
                Task {
                    await websocket.disconnect(response: true)
                }
                clientData.networking.ready = false
            }
        }
        .navigationTitle("Settings")
    }
}

struct FixturesSetupView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    var body: some View {
        List {
            NavigationLink("Templates") {
                
            }
            .disabled(true)
            NavigationLink("Fixture Configuration") {
                FixtureConfigurationView(clientData: $clientData, packet: $packet, websocket: $websocket)
            }
            NavigationLink("Groups") {
                FixtureGroupConfigurationView(clientData: $clientData, packet: $packet, websocket: $websocket)
            }
        }
        .navigationTitle("Fixtures")
    }
}

struct FixtureGroupConfigurationView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    var body: some View {
        List {
            ForEach($packet.fixtureGroups.fixtureGroups.wrappedValue.indices, id: \.self) { index in
                NavigationLink($packet.fixtureGroups.fixtureGroups.wrappedValue[index].name) {
                    
                }
                .swipeActions(allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                .contextMenu {
                    Button("Duplicate") {
                        
                    }
                    Button("Delete", role: .destructive) {
                        
                    }
                }
            }
        }
        .navigationTitle("Fixture Groups")
        .toolbar {
            Button {
                
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

///Zwischenablage
struct FixtureConfigurationView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    
    @State var selectedFixtures: [Fixture] = []
    @State var selectable: Bool = false
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach($packet.fixtures.fixtures.wrappedValue.indices, id: \.self) { index in
                    if $selectable.wrappedValue {
                        Button {
                            if $selectedFixtures.wrappedValue.contains($packet.fixtures.fixtures.wrappedValue[index]) {
                                selectedFixtures.remove(at: selectedFixtures.firstIndex(of: $packet.fixtures.fixtures.wrappedValue[index])!)
                            } else {
                                selectedFixtures.append($packet.fixtures.fixtures.wrappedValue[index])
                            }
                        } label: {
                            SingleFixtureGridView(fixture: $packet.fixtures.fixtures[index], selectedFixtures: $selectedFixtures, contextMenu: false) {
                                //Copy
                            } onPaste: {
                                //Paste
                            } onDuplicate: {
                                //Duplicate
                            } onDelete: {
                                //Delete
                            }
                        }
                    } else {
                        NavigationLink {
                            
                        } label: {
                            SingleFixtureGridView(fixture: $packet.fixtures.fixtures[index], selectedFixtures: $selectedFixtures) {
                                //Copy
                            } onPaste: {
                                //Paste
                            } onDuplicate: {
                                //Duplicate
                            } onDelete: {
                                //Delete
                            }
                            .buttonStyle(.plain)
                            .accentColor(.primary)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Fixture Configuration")
        .toolbar {
            Button {
                selectable.toggle()
                selectedFixtures = []
            } label: {
                if $selectable.wrappedValue {
                    Text("Cancel")
                } else {
                    Text("Select")
                }
            }
            Button {
                
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct SingleFixtureGridView: View {
    @Binding var fixture: Fixture
    @Binding var selectedFixtures: [Fixture]
    
    @State var contextMenu: Bool?
    
    var onCopy: () -> Void
    var onPaste: () -> Void
    var onDuplicate: () -> Void
    var onDelete: () -> Void
    var body: some View {
        if contextMenu ?? true {
            ZStack {
                if $selectedFixtures.wrappedValue.contains($fixture.wrappedValue) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.purple)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        .aspectRatio(1/1, contentMode: .fit)
                        .clipped()
                        .clipped()
                }
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemFill))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .aspectRatio(1/1, contentMode: .fit)
                    .clipped()
                    .clipped()
                VStack {
                    Text($fixture.wrappedValue.name)
                        .font(.body)
                        .frame(width: 110, height: 50)
                        .clipped()
                }
            }
            .contextMenu {
                Button("Copy") {
                    onCopy()
                }
                Button("Paste") {
                    onPaste()
                }
                Button("Duplicate") {
                    onDuplicate()
                }
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
        } else {
            ZStack {
                if $selectedFixtures.wrappedValue.contains($fixture.wrappedValue) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.purple)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        .aspectRatio(1/1, contentMode: .fit)
                        .clipped()
                        .clipped()
                }
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemFill))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .aspectRatio(1/1, contentMode: .fit)
                    .clipped()
                    .clipped()
                VStack {
                    Text($fixture.wrappedValue.name)
                        .font(.body)
                        .frame(width: 110, height: 50)
                        .clipped()
                }
            }
        }
    }
}

struct iPadSettingsView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    
    @State var selectedDisplayMode: DisplayMode = .left
    var body: some View {
        List {
            Picker("iPad Display Mode", selection: $selectedDisplayMode) {
                ForEach(DisplayMode.allCases, id: \.self) { index in
                    Text(index.rawValue.capitalizingFirstLetter())
                        .tag(index)
                }
            }
        }
        .navigationTitle("iPad Settings")
        .task {
            selectedDisplayMode = $clientData.meta.displayMode.wrappedValue
        }
    }
}
    

#Preview {
    SetupView(clientData: .constant(ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: true, step: 1), meta: ClientMeta(displayMode: .left))), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: [FixtureTemplate(internalID: "1", name: "Hello", channels: [Channel(internalID: "1", ChannelName: "Milan", ChannelType: "Milan", dmxChannel: "1"), Channel(internalID: "2", ChannelName: "Johannes", ChannelType: "Johannes", dmxChannel: "2")]), FixtureTemplate(internalID: "2", name: "Hugo", channels: [])]), fixtures: FixtureList(fixtures: [Fixture(internalID: "1", name: "Thorsten", startChannel: "1", selected: "false", channels: [Channel(internalID: "3982", ChannelName: "Henriette", ChannelType: "Master", dmxChannel: "39")]), Fixture(internalID: "2", name: "Hans", startChannel: "1", selected: "true", channels: [])]), fixtureGroups: FixtureGroupList(fixtureGroups: [FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "PeterAAAHHAHHAHHAHHAHHAHHAHHAHHAHAHAHHAHHAHAHHAHHAHHAHHA", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"), FixtureGroup(name: "", groupID: "", internalIDs: [], selected: "false")]), mixer: Mixer(pages: [MixerPage(num: "1", faders: [MixerFader(name: "Herbert", color: "#ffffff", isTouched: "false", value: "255", assignedType: "Fixture", assignedID: "1", id: "1")], buttons: [MixerButton(name: "Karsten", color: "#ffffff", isPressed: "true", assignedType: "FixtureGroup", assignedID: "1", id: "2")], id: "3")], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false"))), websocket: .constant(WebSocket(cnw: .constant(ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false)), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false"))))), navigationMode: .view)
}
