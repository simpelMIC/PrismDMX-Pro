//
//  ContentView.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI

struct ParentView: View {
    @State var clientData: ClientData = ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: true, step: 1), meta: ClientMeta(displayMode: .left))
    @State var packet: Packet = /*Packet(fixtureTemplates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(availableProjects: [], setup: "false", channels: "false"))*/Packet(fixtureTemplates: FixtureTemplateList(templates: [FixtureTemplate(internalID: "1", name: "Hello", channels: [Channel(internalID: "1", ChannelName: "Milan", ChannelType: "Milan", dmxChannel: "1"), Channel(internalID: "2", ChannelName: "Johannes", ChannelType: "Johannes", dmxChannel: "2")]), FixtureTemplate(internalID: "2", name: "Hugo", channels: [])]), fixtures: FixtureList(fixtures: [Fixture(internalID: "1", name: "Thorsten", startChannel: "1", selected: "false", channels: [Channel(internalID: "3982", ChannelName: "Henriette", ChannelType: "Master", dmxChannel: "39")]), Fixture(internalID: "2", name: "Hans", startChannel: "1", selected: "true", channels: [])]), fixtureGroups: FixtureGroupList(fixtureGroups: [FixtureGroup(name: "Peter", groupID: "1", internalIDs: ["1", "2"], selected: "false"), FixtureGroup(name: "Jürgen", groupID: "2", internalIDs: [], selected: "true")]), mixer: Mixer(pages: [MixerPage(num: "1", faders: [MixerFader(name: "Herbert", color: "#ffffff", isTouched: "false", value: "255", assignedType: "Fixture", assignedID: "1", id: "1")], buttons: [MixerButton(name: "Karsten", color: "#ffffff", isPressed: "true", assignedType: "FixtureGroup", assignedID: "1", id: "2")], id: "3")], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "1", name: "MLS Kleinkunst"), availableProjects: [Project(internalID: "1", name: "MLS Kleinkunst")], setup: "false", channels: "false"))
    var body: some View {
        MainView(clientData: $clientData, packet: $packet, websocket: WebSocket(cnw: $clientData.networking, packet: $packet))
    }
}

struct MainView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @State var websocket: WebSocket
    var body: some View {
        VStack {
            if $clientData.onboarding.ready.wrappedValue == true {
                if clientData.networking.connected == false && clientData.networking.error == nil {
                    NWSettingsView(clientData: $clientData, packet: $packet, websocket: $websocket)
                } else if clientData.networking.connected == false && clientData.networking.error != nil {
                    NWSettingsView(clientData: $clientData, packet: $packet, websocket: $websocket)
                } else if clientData.networking.connected == true && clientData.networking.error == nil {
                    if $packet.meta.currentProject.wrappedValue == nil {
                        NavigationStack {
                            ProjectSelectionView(clientData: $clientData, packet: $packet, websocket: $websocket, disconnectButton: true)
                        }
                    } else {
                        if $clientData.meta.displayMode.wrappedValue == .left {
                            MainLeftView(clientData: $clientData, packet: $packet, websocket: $websocket)
                        } else {
                            MainRightView(clientData: $clientData, packet: $packet, websocket: $websocket)
                        }
                    }
                } else if clientData.networking.connected == true && clientData.networking.error != nil {
                    NWSettingsView(clientData: $clientData, packet: $packet, websocket: $websocket)
                } else {
                    Text("Unexpected Error")
                        .task {
                            clientData.networking.error = "Unexpected Networking CaseError"
                        }
                }
            } else {
                //WelcomeScreen
                if $clientData.onboarding.step.wrappedValue == 0 || $clientData.onboarding.step.wrappedValue == 1 {
                    WelcomingScreen()
                        .onTapGesture {
                            clientData.onboarding.step = 1
                        }
                        .sheet(isPresented: Binding<Bool>(
                            get: { clientData.onboarding.step == 1 },
                            set: { if !$0 { clientData.onboarding.step = 0 } }
                        ), content: {
                            Button("Begin your experience") {
                                //Begin Networking Settings
                                clientData.onboarding.ready = true
                                ClientDataModule().save(clientData)
                            }
                            .buttonStyle(.borderedProminent)
                        })
                }
            }
        }
        .task {
            //Load previous saved Data :: If nothing is found it will load default data
            clientData = ClientDataModule().load() ?? ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: false, step: 0), meta: ClientMeta(displayMode: .left))
        }
    }
}

#Preview {
    ParentView()
}
