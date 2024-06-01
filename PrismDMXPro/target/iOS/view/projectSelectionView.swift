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
    var body: some View {
        NavigationStack {
            List($packet.meta.availableProjects.wrappedValue.indices, id: \.self) { project in
                Button($packet.meta.availableProjects[project].name.wrappedValue) {
                    Task {
                        await websocket.sendString("{\"setProject\": \"\($packet.meta.availableProjects[project].internalID)\"}", response: true)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Available Projects")
        }
    }
}
