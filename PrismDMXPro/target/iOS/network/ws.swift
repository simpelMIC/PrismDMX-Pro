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

///#PMX Websocket Module
/*
 ### Classes and Structs:
 1. `WebSocket`:
     - Inherits from `WebSocketConnectionDelegate`.
     - Has properties:
         - `socket`: An optional instance of `NWWebSocket`.
         - `cnw`: A binding to `ClientNetworking`.
         - `packet`: A binding to `Packet`.

 ### Functions:
 1. `init(cnw:packet:)`:
     - Initializes a new instance of `WebSocket`.
     - Takes two bindings, `cnw` and `packet`, and assigns them to respective properties.

 2. `connect(cprotocol:ip:port:path:)`:
     - Establishes a connection with the WebSocket server.
     - Takes parameters for the client network protocol, IP, port, and path.
     - Constructs a URL based on the provided parameters.
     - Attempts to connect to the WebSocket using the constructed URL.

 3. `connectToSocket(_:)`:
     - Connects to the WebSocket server using the provided URL.

 4. `disconnect(response:)`:
     - Disconnects from the WebSocket server.
     - Optionally prints a message if `response` is true.

 5. `sendBindingString(_:response:)`:
     - Sends a string asynchronously to the WebSocket server.
     - Accepts a binding string and an optional response flag.

 6. `sendString(_:response:)`:
     - Sends a string asynchronously to the WebSocket server.
     - Accepts a string and an optional response flag.

 7. WebSocketConnectionDelegate methods:
     - These methods are required by the `WebSocketConnectionDelegate` protocol and handle various events related to WebSocket connection.

 ### Extension:
 1. Extension to `NWWebSocket`:
     - Adds asynchronous versions of connection, disconnection, and sending messages.
     - `connectAsync()`: Asynchronously connects to the WebSocket server.
     - `disconnectAsync()`: Asynchronously disconnects from the WebSocket server.
     - `sendAsync(string:)`: Asynchronously sends a string message to the WebSocket server.
 */

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
        packet = PacketJSONModule(currentPacket: $packet).decodePacket(from: string) ?? Packet(fixtureTemplates: FixtureTemplateList(templates: []), fixtures: FixtureList(fixtures: []), fixtureGroups: FixtureGroupList(fixtureGroups: []), mixer: Mixer(pages: [], color: "#ffffff", isMixerAvailable: "false", mixerType: "0"), meta: Meta(currentProject: Project(internalID: "error", name: "error at webSocketReciever"), availableProjects: []))
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
