//
//  projectSelectionView.swift
//  PrismDMXPro
//
//  Created by Christian on 01.06.24.
//

import Foundation
import SwiftUI

struct ProjectSelectionView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    
    @State var isSheetPresented: Bool = false
    @State var sheetProjectName: String = "New Project"
    @State var disconnectButton: Bool?
    var body: some View {
            List($packet.meta.availableProjects.wrappedValue.indices, id: \.self) { project in
                Button($packet.meta.availableProjects[project].name.wrappedValue) {
                    Task {
                        await websocket.sendString("{\"setProject\": \"\($packet.meta.availableProjects[project].wrappedValue.internalID)\"}", response: true)
                    }
                }
                .accentColor(.white)
            }
            .navigationTitle("Choose a project")
            .toolbar {
                HStack {
                    if $disconnectButton.wrappedValue ?? true {
                        Button("Disconnect") {
                            Task {
                                await websocket.disconnect(response: true)
                            }
                            clientData.networking.ready = false
                        }
                    }
                    Button {
                        isSheetPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        .sheet(isPresented: $isSheetPresented, content: {
            NewProjectSheetView(projectName: $sheetProjectName) {
                Task {
                    await websocket.sendString("{\"newProject\": \"\($sheetProjectName.wrappedValue)\"}", response: true)
                }
                isSheetPresented.toggle()
            }
        })
    }
}

struct NewProjectSheetView: View {
    @Binding var projectName: String
    var onSubmit: () -> Void
    
    var body: some View {
        VStack {
            Text("New Project")
                .font(.title)
            HStack {
                Text("Name:")
                TextField("Name", text: $projectName)
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

#Preview {
    ProjectSelectionView(clientData: .constant(ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: true, step: 1), meta: ClientMeta(displayMode: .left))), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: [FixtureTemplate(internalID: "1", name: "Hello", channels: [Channel(internalID: "1", ChannelName: "Milan", ChannelType: "Milan", dmxChannel: "1"), Channel(internalID: "2", ChannelName: "Johannes", ChannelType: "Johannes", dmxChannel: "2")]), FixtureTemplate(internalID: "2", name: "Hugo", channels: [])]), fixtures: FixtureList(fixtures: [Fixture(internalID: "1", name: "Thorsten", startChannel: "1", selected: "false", channels: [Channel(internalID: "3982", ChannelName: "Henriette", ChannelType: "Master", dmxChannel: "39")]), Fixture(internalID: "2", name: "Hans", startChannel: "1", selected: "true", channels: [])]), fixtureGroups: FixtureGroupList(fixtureGroups: [FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"), FixtureGroup(name: "Jürgen", groupID: "2", internalIDs: [], selected: "true")]), mixer: Mixer(pages: [MixerPage(num: "1", faders: [MixerFader(name: "Herbert", color: "#ffffff", isTouched: "false", value: "255", assignedType: "Fixture", assignedID: "1", id: "1")], buttons: [MixerButton(name: "Karsten", color: "#ffffff", isPressed: "true", assignedType: "FixtureGroup", assignedID: "1", id: "2")], id: "3")], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false"))), websocket: .constant(WebSocket(cnw: .constant(ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false)), packet: .constant(Packet(fixtureTemplates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false"))))))
    //NewProjectSheetView(projectName: .constant("New Project"), onSubmit: {})
}
