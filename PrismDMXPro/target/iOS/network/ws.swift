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
    
    init(cnw: Binding<ClientNetworking>) {
        self._cnw = cnw
    }
    
    // Connection
    
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
        
        print("Connecting to \(url)")
        await connectToSocket(url: url, response: true)
    }

    func connectToSocket(url: URL, response: Bool) async {
        self.socket = NWWebSocket(url: url)
        self.socket?.delegate = self
        await self.socket?.connectAsync()
        if response {
            print("WebSocket connected to: \(url)")
        }
    }
    
    func disconnect(response: Bool) async {
        await socket?.disconnectAsync()
        if response {
            print("WebSocket disconnected")
        }
    }
    
    // Data
    
    func sendBindingString(_ string: Binding<String>, response: Bool) async {
        await socket?.sendAsync(string: string.wrappedValue)
        if response {
            print("Sent message: \(string.wrappedValue)")
        }
    }
    
    func sendString(_ string: String, response: Bool) async {
        await socket?.sendAsync(string: string)
        if response {
            print("Sent message: \(string)")
        }
    }
    
    // WebSocketConnectionDelegate methods
    
    func webSocketDidConnect(connection: WebSocketConnection) {
        print("WebSocket connected")
        cnw.connected = true
        cnw.error = nil
    }

    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        print("WebSocket disconnected with code: \(closeCode)")
        cnw.connected = false
        cnw.error = "Disconnected"
    }

    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        print("WebSocket viability changed to: \(isViable)")
    }

    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        print("WebSocket attempted better path migration")
    }

    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        print("WebSocket received error: \(error)")
        cnw.error = error.localizedDescription
        Task {
            await self.disconnect(response: true)
        }
    }

    func webSocketDidReceivePong(connection: WebSocketConnection) {
        print("WebSocket received Pong")
    }

    func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String) {
        print("WebSocket received message as string: \(string)")
    }

    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        print("WebSocket received message as data: \(data)")
        cnw.error = "Untrusted Source"
        Task {
            await self.disconnect(response: true)
        }
    }
}

extension NWWebSocket {
    func connectAsync() async {
        await withCheckedContinuation { continuation in
            self.connect()
            continuation.resume()
        }
    }
    
    func disconnectAsync() async {
        await withCheckedContinuation { continuation in
            self.disconnect()
            continuation.resume()
        }
    }
    
    func sendAsync(string: String) async {
        await withCheckedContinuation { continuation in
            self.send(string: string)
            continuation.resume()
        }
    }
}
