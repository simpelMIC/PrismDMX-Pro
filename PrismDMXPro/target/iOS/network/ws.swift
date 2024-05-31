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

class Websocket: WebSocketConnectionDelegate {
    var socket: NWWebSocket?
    
    @Binding var cnw: ClientNetworking
    
    init(cnw: Binding<ClientNetworking>) {
        self._cnw = cnw
    }
    
    //Connection
    
    func connect(cprotocol: ClientNWProtocol, ip: String, port: String, path: String) {
        //Generate protocol
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
        
        if port.isEmpty {
            // Check if the IP is a valid URL
            guard let url = URL(string: "\(myProtocol)\(ip)\(path)") else {
                // Print an error message or handle the invalid URL case as needed
                cnw.error = "Invalid URL: \(myProtocol)\(ip)\(path)"
                return
            }
            print("Connecting to \(url)")
            connectToSocket(url: url, response: true)
        } else {
            // Check if the IP is a valid URL
            guard let url = URL(string: "\(myProtocol)\(ip):\(port)\(path)") else {
                // Print an error message or handle the invalid URL case as needed
                cnw.error = "Invalid URL: \(myProtocol)\(ip):\(port)\(path)"
                return
            }
            print("Connecting to \(url)")
            connectToSocket(url: url, response: true)
        }
    }

    func connectToSocket(url: URL, response: Bool) {
        self.socket = NWWebSocket(url: url)
        self.socket?.delegate = self
        self.socket?.connect()
        if response {
            print("Websocket connected to: \(url)")
        }
    }
    
    func disconnect(response: Bool) {
        socket?.disconnect()
        if response == true {
            print("Websocket disconnect")
        }
    }
    
    //Data
    
    func sendBindingString(_ string: Binding<String>, response: Bool) {
        socket?.send(string: string.wrappedValue)
        if response == true {
            print("Sent message: \(string)")
        }
    }
    
    func sendString(_ string: String, response: Bool) {
        socket?.send(string: string)
        if response == true {
            print("Sent message: \(string)")
        }
    }
    
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
        self.disconnect(response: true)
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
        self.disconnect(response: true)
    }
}
