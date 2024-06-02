//
//  mixerView.swift
//  PrismDMXPro
//
//  Created by Christian on 02.06.24.
//

import Foundation
import SwiftUI

struct MixerView: View {
    @Binding var clientData: ClientData
    @Binding var packet: Packet
    @Binding var websocket: WebSocket
    var body: some View {
        Text("Mixer")
    }
}
