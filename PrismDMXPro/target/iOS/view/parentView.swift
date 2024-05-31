//
//  ContentView.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI

struct ParentView: View {
    @State var clientData: ClientData = ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: false, step: 0))
    @State var packet: Packet = Packet(templates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"))
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
                    //Workspace
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
            clientData = ClientDataModule().load() ?? ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: false, step: 0))
        }
    }
}

#Preview {
    ParentView()
}
