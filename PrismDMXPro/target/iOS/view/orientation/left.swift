//
//  left.swift
//  PrismDMXPro
//
//  Created by Christian on 01.06.24.
//

import Foundation
import SwiftUI
import PageView

struct MainLeftView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    
    @State var currentGroup: FixtureGroup?
    @State var currentPage: Int = 0
    var body: some View {
        if $packet.mixer.isMixerAvailable.wrappedValue == "true" {
            if $packet.meta.setup.wrappedValue == "true" {
                SetupView(clientData: $clientData, packet: $packet, websocket: $websocket)
            } else {
                if $packet.meta.channels.wrappedValue == "true" {
                    FixtureView(clientData: $clientData, packet: $packet, websocket: $websocket)
                } else {
                    MixerView(clientData: $clientData, packet: $packet, websocket: $websocket)
                }
            }
        } else {
            TabView {
                MixerView(clientData: $clientData, packet: $packet, websocket: $websocket)
                    .tabItem { Text("Mixer") }
                FixtureView(clientData: $clientData, packet: $packet, websocket: $websocket)
                    .tabItem { Text("Fixture") }
                SetupView(clientData: $clientData, packet: $packet, websocket: $websocket, navigationMode: .stack)
                    .tabItem { Text("Setup") }
            }
        }
    }
}

struct FixtureView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach($packet.fixtureGroups.fixtureGroups.wrappedValue.indices, id: \.self) { index in
                                    Button {
                                        if $packet.fixtureGroups.fixtureGroups.wrappedValue[index].selected.bool() {
                                            deselectFixtureGroup($packet.fixtureGroups.fixtureGroups.wrappedValue[index].groupID)
                                        } else {
                                            selectFixtureGroup($packet.fixtureGroups.fixtureGroups.wrappedValue[index].groupID)
                                        }
                                    } label: {
                                        SingleFixtureGroup(selected: $packet.fixtureGroups.fixtureGroups[index].selected, name: $packet.fixtureGroups.fixtureGroups[index].name)
                                            .scrollTransition(topLeading: .interactive, bottomTrailing: .interactive, axis: .horizontal) { effect, phase in
                                                effect
                                                    .scaleEffect(1 - abs(phase.value))
                                                    .opacity(1 - abs(phase.value))
                                                    .rotation3DEffect(.degrees(1 - phase.value * 90), axis: (x: 0, y: 1, z: 0))
                                                
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(height: 200)
                        .safeAreaPadding(.horizontal, 19)
                        .scrollClipDisabled()
                        .scrollTargetBehavior(.viewAligned)
                        .scrollTargetLayout()
                        
                        //------\\
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach($packet.fixtures.fixtures.wrappedValue.indices, id: \.self) { index in // Replace with your data model here
                                Button {
                                    if $packet.fixtures.fixtures.wrappedValue[index].selected.bool() {
                                        deselectFixture($packet.fixtures.fixtures.wrappedValue[index].internalID)
                                    } else {
                                        selectFixture($packet.fixtures.fixtures.wrappedValue[index].internalID)
                                    }
                                } label: {
                                    ZStack {
                                        if $packet.fixtures.fixtures.wrappedValue[index].selected == "true" {
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .fill(.purple)
                                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                                                .aspectRatio(1/1, contentMode: .fit)
                                                .clipped()
                                                .clipped()
                                        } else {
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .fill(Color(.systemFill))
                                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                                                .aspectRatio(1/1, contentMode: .fit)
                                                .clipped()
                                                .clipped()
                                        }
                                        VStack {
                                            Image(systemName: "lightbulb.fill")
                                                .imageScale(.large)
                                                .symbolRenderingMode(.monochrome)
                                                .font(.system(size: 20, weight: .regular, design: .default))
                                            Text($packet.fixtures.fixtures.wrappedValue[index].name)
                                                .font(.body)
                                                .frame(width: 110, height: 50)
                                                .clipped()
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle(packet.meta.currentProject?.name ?? "Workspace")
            }
    }
    
    func selectFixture(_ id: String) {
        Task {
            await websocket.sendString("{\"selectFixture\": \"\(id)\"}", response: true)
        }
    }
    
    func deselectFixture(_ id: String) {
        Task {
            await websocket.sendString("{\"deselectFixture\": \"\(id)\"}", response: true)
        }
    }
    
    func selectFixtureGroup(_ id: String) {
        Task {
            await websocket.sendString("{\"selectFixtureGroup\": \"\(id)\"}", response: true)
        }
    }
    
    func deselectFixtureGroup(_ id: String) {
        Task {
            await websocket.sendString("{\"deselectFixtureGroup\": \"\(id)\"}", response: true)
        }
    }
}

struct SingleFixtureGroup: View {
    @Binding var selected: String
    @Binding var name: String
    
    @State var frameSize: CGFloat = 194
    var body: some View {
        ZStack {
            if $selected.wrappedValue == "true" {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.purple)
                    .frame(width: frameSize, height: frameSize)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemFill))
                    .frame(width: frameSize, height: frameSize)
                    .clipped()
            }
            VStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 50))
                Text($name.wrappedValue)
                    .font(.system(size: 20))
                    .frame(width: 160, height: 50)
                    .clipped()
            }
        }
    }
}

#Preview {
    MainLeftView(clientData: .constant(ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: true, step: 1), meta: ClientMeta(displayMode: .left))), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: [FixtureTemplate(internalID: "1", name: "Hello", channels: [Channel(internalID: "1", ChannelName: "Milan", ChannelType: "Milan", dmxChannel: "1"), Channel(internalID: "2", ChannelName: "Johannes", ChannelType: "Johannes", dmxChannel: "2")]), FixtureTemplate(internalID: "2", name: "Hugo", channels: [])]), fixtures: FixtureList(fixtures: [Fixture(internalID: "1", name: "Thorsten", startChannel: "1", selected: "false", channels: [Channel(internalID: "3982", ChannelName: "Henriette", ChannelType: "Master", dmxChannel: "39")]), Fixture(internalID: "2", name: "Hans", startChannel: "1", selected: "true", channels: [])]), fixtureGroups: FixtureGroupList(fixtureGroups: [FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "PeterAAAHHAHHAHHAHHAHHAHHAHHAHHAHAHAHHAHHAHAHHAHHAHHAHHA", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"),FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"), FixtureGroup(name: "", groupID: "", internalIDs: [], selected: "false")]), mixer: Mixer(pages: [MixerPage(num: "1", faders: [MixerFader(name: "Herbert", color: "#ffffff", isTouched: "false", value: "255", assignedType: "Fixture", assignedID: "1", id: "1")], buttons: [MixerButton(name: "Karsten", color: "#ffffff", isPressed: "true", assignedType: "FixtureGroup", assignedID: "1", id: "2")], id: "3")], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false", clipboard: ""))), websocket: .constant(WebSocket(cnw: .constant(ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false)), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false", clipboard: ""))))))
}
