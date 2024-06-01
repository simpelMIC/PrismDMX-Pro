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
    var body: some View {
        NavigationStack {
            List($packet.meta.availableProjects.wrappedValue.indices, id: \.self) { project in
                Button($packet.meta.availableProjects[project].name.wrappedValue) {
                    Task {
                        await websocket.sendString("{\"setProject\": \"\($packet.meta.availableProjects[project].internalID)\"}", response: true)
                    }
                }
                .accentColor(.white)
            }
            .navigationTitle("Available Projects")
            .toolbar {
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
            }
        })
    }
}

struct NewProjectSheetView: View {
    @Binding var projectName: String
    var onSubmit: () -> Void
    
    var body: some View {
        Text("New Project")
        TextField("Name", text: $projectName)
        Button("Submit") {
            onSubmit()
        }
        .buttonStyle(.borderedProminent)
    }
}
