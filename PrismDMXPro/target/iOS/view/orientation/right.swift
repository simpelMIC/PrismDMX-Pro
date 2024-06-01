//
//  right.swift
//  PrismDMXPro
//
//  Created by Christian on 01.06.24.
//

import Foundation
import SwiftUI

struct MainRightView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    var body: some View {
        Text("Workspace Right")
    }
}
