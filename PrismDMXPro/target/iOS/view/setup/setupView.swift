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
            NavigationLink("Fixture Schedule") {
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
            NavigationLink("Fixtures") {
                FixtureConfigurationView(clientData: $clientData, packet: $packet, websocket: $websocket)
            }
            NavigationLink("Groups") {
                FixtureGroupConfigurationView(clientData: $clientData, packet: $packet, websocket: $websocket)
            }
        }
        .navigationTitle("Fixture Schedule")
    }
}

struct FixtureGroupConfigurationView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    
    @State var isSheetPresented: Bool = false
    @State var newFixtureGroupName: String = "New Fixture Group"
    var body: some View {
        List {
            ForEach($packet.fixtureGroups.fixtureGroups.wrappedValue.indices, id: \.self) { index in
                NavigationLink($packet.fixtureGroups.fixtureGroups.wrappedValue[index].name) {
                    FixtureGroupDetailView(packet: $packet, websocket: $websocket, group: $packet.fixtureGroups.fixtureGroups[index])
                }
                .swipeActions(allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteGroup(id: $packet.fixtureGroups.fixtureGroups.wrappedValue[index].groupID)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                .contextMenu {
                    Button("Delete", role: .destructive) {
                        deleteGroup(id: $packet.fixtureGroups.fixtureGroups.wrappedValue[index].groupID)
                    }
                }
            }
        }
        .navigationTitle("Fixture Groups")
        .toolbar {
            Button {
                isSheetPresented.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $isSheetPresented, content: {
            NewFixtureGroup(name: $newFixtureGroupName) {
                appendNewFixtureGroup(name: $newFixtureGroupName.wrappedValue)
                isSheetPresented.toggle()
            }
        })
    }
    
    func appendNewFixtureGroup(name: String) {
        Task {
            await websocket.sendString("{\"newGroup\": \"\(name)\"}", response: true)
        }
    }
    
    func deleteGroup(id: String) {
        Task {
            await websocket.sendString("{\"deleteGroup\": \"\(id)\"}", response: true)
        }
    }
}

struct FixtureGroupDetailView: View {
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    @Binding var group: FixtureGroup
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("Name:")
                    TextField("Name", text: $group.name)
                }
            }
            .navigationTitle($group.name.wrappedValue)
            .scrollDisabled(true)
            .frame(height: 50)
            HStack {
                List {
                    ForEach(packet.fixtures.fixtures.indices, id: \.self) { index in
                        Button {
                            Task {
                                await websocket.sendString("{\"addFixtureToGroup\": {\"groupID\":\"\(group.groupID)\", \"fixtureID\":\"\(packet.fixtures.fixtures[index].internalID)\"}}", response: true)
                            }
                        } label: {
                            Text(packet.fixtures.fixtures[index].name)
                        }
                    }
                }
                List {
                    ForEach(group.internalIDs.indices, id: \.self) { index in
                        if let fixture = packet.fixtures.fixtures.first(where: { $0.internalID == group.internalIDs[index] }) {
                            Button(role: .destructive) {
                                Task {
                                    await websocket.sendString("{\"removeFixtureFromGroup\": {\"groupID\":\"\(group.groupID)\", \"fixtureID\":\"\(fixture.internalID)\"}}", response: true)
                                }
                            } label: {
                                Text(fixture.name)
                            }
                        }
                    }
                }
            }
        }
    }
}


struct NewFixtureGroup: View {
    @Binding var name: String
    
    var onSubmit: () -> Void
    var body: some View {
        VStack {
            Text("New Group")
                .font(.title)
            HStack {
                Text("Name:")
                TextField("Name", text: $name)
            }
            Spacer()
            Button("Create") {
                onSubmit()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
    }
}

///Zwischenablage
struct FixtureConfigurationView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    
    @State var selectedFixtures: [Fixture] = []
    @State var selectable: Bool = false
    
    @State var isSheetPresented: Bool = false
    @State var sheetFixture: Fixture = Fixture(internalID: "n/a", name: "New Fixture", startChannel: "1", selected: "false", channels: [])
    
    var body: some View {
        List {
            ForEach($packet.fixtures.fixtures.wrappedValue.indices, id: \.self) { index in
                if selectable {
                    if $selectedFixtures.wrappedValue.contains($packet.fixtures.fixtures.wrappedValue[index]) {
                        Button {
                            selectedFixtures.remove(at: selectedFixtures.firstIndex(of: $packet.fixtures.fixtures.wrappedValue[index])!)
                        } label: {
                            HStack {
                                Image(systemName: "circle.inset.filled")
                                Text($packet.fixtures.fixtures.wrappedValue[index].name)
                            }
                        }
                    } else {
                        Button {
                            selectedFixtures.append($packet.fixtures.fixtures.wrappedValue[index])
                        } label: {
                            HStack {
                                Image(systemName: "circle")
                                Text($packet.fixtures.fixtures.wrappedValue[index].name)
                            }
                        }
                    }
                } else {
                    NavigationLink {
                        FixtureDetailView(websocket: $websocket, packet: $packet, fixture: $packet.fixtures.fixtures.wrappedValue[index])
                    } label: {
                        Text($packet.fixtures.fixtures.wrappedValue[index].name)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteFixture(id: $packet.fixtures.fixtures.wrappedValue[index].internalID)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            deleteFixture(id: $packet.fixtures.fixtures.wrappedValue[index].internalID)
                        }
                    }
                }
            }
        }
        .navigationTitle("Fixtures")
        .toolbar {
            Button {
                selectable.toggle()
                selectedFixtures = []
            } label: {
                if selectable {
                    Text("Cancel")
                } else {
                    Text("Select")
                }
            }
            Button {
                isSheetPresented.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $isSheetPresented, content: {
            NewFixtureView(packet: $packet, websocket: $websocket, isSheetPresented: $isSheetPresented)
        })
    }
    
    func deleteFixture(id: String) {
        Task {
            await websocket.sendString("{\"deleteFixture\": \"\(id)\"}", response: true)
        }
    }
}

struct FixtureDetailView: View {
    @Binding var websocket: WebSocket
    @Binding var packet: Packet
    @State var fixture: Fixture
    var body: some View {
        List {
            HStack {
                Text("Name:")
                TextField("Name", text: $fixture.name)
            }
            HStack {
                Text("Start Channel:")
                TextField("Start Channel", text: $fixture.startChannel)
            }
        }
        .navigationTitle($fixture.name.wrappedValue)
        .toolbar {
            Button("Save") {
                updateFixture()
            }
        }
        .onDisappear() {
            updateFixture()
        }
    }
    
    func updateFixture() {
        Task {
            let jsonString = PacketJSONModule(currentPacket: $packet).encode($fixture.wrappedValue) ?? ""
            await websocket.sendString("{\"editFixture\":\(jsonString)}", response: true)
        }
    }
}

struct NewFixtureView: View {
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    @Binding var isSheetPresented: Bool
    
    @State private var selection: FixtureTemplate?
    @State private var newFixture: Fixture = Fixture(internalID: "", name: "", startChannel: "", selected: "", channels: [])
    @State private var selectedIndex: Int = 0
    
    private var selectedTemplate: FixtureTemplate {
        return packet.fixtureTemplates.templates[selectedIndex]
    }

    var body: some View {
        VStack {
            Text("New Fixture")
                .font(.title)
                .fontWeight(.black)
            HStack {
                Text("Name: ")
                TextField("Name", text: $newFixture.name)
            }
            HStack {
                Text("Starting Channel: ")
                TextField("Channel", text: $newFixture.startChannel)
            }
            HStack {
                Text("Pick a template: ")
                Picker("Pick a template", selection: $selectedIndex) {
                    ForEach(packet.fixtureTemplates.templates.indices, id: \.self) { index in
                        Text(packet.fixtureTemplates.templates[index].name)
                    }
                }
            }
            Spacer()
            HStack {
                Button {
                    isSheetPresented = false
                    fillDefaultsAndRequestNewFixture()
                } label: {
                    Text("Create")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
    }
    
    func fillDefaultsAndRequestNewFixture() {
        if newFixture.name.isEmpty {
            newFixture.name = selectedTemplate.name
        }
        
        if newFixture.startChannel.isEmpty {
            newFixture.startChannel = selectedTemplate.channels.first?.dmxChannel ?? "1"
        }
        
        if newFixture.channels.isEmpty {
            newFixture.channels = selectedTemplate.channels
        }
        
        requestNewFixture()
    }
    
    func requestNewFixture() {
        Task {
            let jsonString = PacketJSONModule(currentPacket: $packet).encode(newFixture) ?? ""
            await websocket.sendString("{\"newFixture\":\(jsonString)}", response: true)
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
    SetupView(clientData: .constant(ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: true, step: 1), meta: ClientMeta(displayMode: .left))), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: [FixtureTemplate(internalID: "1", name: "Hello", channels: [Channel(internalID: "1", ChannelName: "Milan", ChannelType: "Milan", dmxChannel: "1"), Channel(internalID: "2", ChannelName: "Johannes", ChannelType: "Johannes", dmxChannel: "2")]), FixtureTemplate(internalID: "2", name: "Hugo", channels: [])]), fixtures: FixtureList(fixtures: [Fixture(internalID: "1", name: "Thorsten", startChannel: "1", selected: "false", channels: [Channel(internalID: "3982", ChannelName: "Henriette", ChannelType: "Master", dmxChannel: "39")]), Fixture(internalID: "2", name: "Hans", startChannel: "1", selected: "true", channels: [])]), fixtureGroups: FixtureGroupList(fixtureGroups: [FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "PeterAAAHHAHHAHHAHHAHHAHHAHHAHHAHAHAHHAHHAHAHHAHHAHHAHHA", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"), FixtureGroup(name: "", groupID: "", internalIDs: [], selected: "false")]), mixer: Mixer(pages: [MixerPage(num: "1", faders: [MixerFader(name: "Herbert", color: "#ffffff", isTouched: "false", value: "255", assignedType: "Fixture", assignedID: "1", id: "1")], buttons: [MixerButton(name: "Karsten", color: "#ffffff", isPressed: "true", assignedType: "FixtureGroup", assignedID: "1", id: "2")], id: "3")], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false", clipboard: ""))), websocket: .constant(WebSocket(cnw: .constant(ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false)), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false", clipboard: ""))))), navigationMode: .view)
}
