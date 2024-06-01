//
//  left.swift
//  PrismDMXPro
//
//  Created by Christian on 01.06.24.
//

import Foundation
import SwiftUI

struct MainLeftView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    var body: some View {
        Text("Workspace Left")
    }
}

struct Untitled: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(0..<5) { _ in // Replace with your data model here
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(.systemFill))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                            .aspectRatio(1/1, contentMode: .fit)
                            .clipped()
                            .clipped()
                        VStack {
                            Image(systemName: "lightbulb.fill")
                                .imageScale(.large)
                                .symbolRenderingMode(.monochrome)
                                .font(.system(size: 20, weight: .regular, design: .default))
                            Text("FIXTUREUTURUEHRIUSHIUFGHDSJKGNFKLJDSNBGJKLDSLKGJNDSJKHF")
                                .font(.body)
                                .frame(width: 110, height: 50)
                                .clipped()
                        }
                    }
                }
            }
            .padding()
        }
    }
}
