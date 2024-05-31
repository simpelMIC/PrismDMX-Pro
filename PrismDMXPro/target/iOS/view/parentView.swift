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
    var body: some View {
        if $clientData.onboarding.ready.wrappedValue == true {
            
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
                        }
                        .buttonStyle(.borderedProminent)
                    })
                    .task {
                        //Load previous saved Data :: If nothing is found it will load default data
                        clientData = ClientDataManager().load() ?? ClientData(networking: ClientNetworking(ready: false, nwProtocol: .ws, ip: "192.168.178.187", port: "8000", path: "/ws/main", connected: false), onboarding: ClientOnboarding(ready: false, step: 0))
                    }
            }
        }
    }
}

#Preview {
    ParentView()
}
