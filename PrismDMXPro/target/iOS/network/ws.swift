//
//  ws.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI
import Network
import NWWebSocket

class WebSocket: WebSocketConnectionDelegate {
    var socket: NWWebSocket?
    
    @Binding var cnw: ClientNetworking
    @Binding var packet: Packet
    
    init(cnw: Binding<ClientNetworking>, packet: Binding<Packet>) {
        self._cnw = cnw
        self._packet = packet
    }
    
    // Connection
    
    // Function to establish a connection with the WebSocket server.
    func connect(cprotocol: ClientNWProtocol, ip: String, port: String, path: String) async {
        // Generate protocol
        let myProtocol: String
        switch cprotocol {
        case .https:
            myProtocol = "https://"
        case .http:
            myProtocol = "http://"
        case .ws:
            myProtocol = "ws://"
        case .wss:
            myProtocol = "wss://"
        }
        
        let urlString: String
        if port.isEmpty {
            urlString = "\(myProtocol)\(ip)\(path)"
        } else {
            urlString = "\(myProtocol)\(ip):\(port)\(path)"
        }
        
        // Check if the URL is valid
        guard let url = URL(string: urlString) else {
            // Handle the invalid URL case
            cnw.error = "Invalid URL: \(urlString)"
            return
        }
        await connectToSocket(url)
    }

    // Function to connect to the WebSocket server using a given URL.
    func connectToSocket(_ url: URL) async {
        self.socket = NWWebSocket(url: url)
        self.socket?.delegate = self
        await self.socket?.connectAsync()
        print("Connecting to \(url)")
    }
    
    // Function to disconnect from the WebSocket server.
    func disconnect(response: Bool) async {
        await socket?.disconnectAsync()
        if response {
            print("WebSocket disconnected")
        }
    }
    
    // Data
    
    // Function to send a string asynchronously to the WebSocket server.
    func sendBindingString(_ string: Binding<String>, response: Bool) async {
        await socket?.sendAsync(string: string.wrappedValue)
        if response {
            print("Sent message: \(string.wrappedValue)")
        }
    }
    
    // Function to send a string asynchronously to the WebSocket server.
    func sendString(_ string: String, response: Bool) async {
        await socket?.sendAsync(string: string)
        if response {
            print("Sent message: \(string)")
        }
    }
    
    // WebSocketConnectionDelegate methods
    
    // WebSocket connected successfully.
    func webSocketDidConnect(connection: WebSocketConnection) {
        print("WebSocket connected to \(connection)")
        cnw.connected = true
        cnw.error = nil
    }

    // WebSocket disconnected with a specific close code and reason.
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        print("WebSocket disconnected with code: \(closeCode)")
        cnw.connected = false
        cnw.error = "Disconnected with code: \(closeCode)"
    }

    // WebSocket viability changed.
    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        print("WebSocket viability changed to: \(isViable)")
    }

    // WebSocket attempted better path migration.
    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        print("WebSocket attempted better path migration")
    }

    // Error occurred on WebSocket connection.
    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        print("WebSocket received error: \(error)")
        cnw.error = error.localizedDescription
        Task {
            await self.disconnect(response: true)
        }
    }

    // WebSocket received a Pong message.
    func webSocketDidReceivePong(connection: WebSocketConnection) {
        print("WebSocket received Pong")
    }

    // WebSocket received a message as a string.
    func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String) {
        print("WebSocket received message as string: \(string)")
        packet = PacketJSONModule(currentPacket: $packet).decodePacket(string)
    }

    // WebSocket received a message as data.
    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        print("WebSocket received message as data: \(data)")
        cnw.error = "Untrusted Source"
        Task {
            await self.disconnect(response: true)
        }
    }
}

// Extension to NWWebSocket to add asynchronous versions of connection, disconnection, and sending messages.
extension NWWebSocket {
    // Asynchronously connect to the WebSocket server.
    func connectAsync() async {
        await withCheckedContinuation { continuation in
            self.connect()
            continuation.resume()
        }
    }
    
    // Asynchronously disconnect from the WebSocket server.
    func disconnectAsync() async {
        await withCheckedContinuation { continuation in
            self.disconnect()
            continuation.resume()
        }
    }
    
    // Asynchronously send a string message to the WebSocket server.
    func sendAsync(string: String) async {
        await withCheckedContinuation { continuation in
            self.send(string: string)
            continuation.resume()
        }
    }
}
