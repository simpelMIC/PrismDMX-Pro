//
//  clientData.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI


enum ClientNWProtocol: String, Codable, CaseIterable {
    case https
    case http
    case ws
    case wss
}

struct ClientData: Codable {
    var networking: ClientNetworking
    var onboarding: ClientOnboarding
}

struct ClientNetworking: Codable {
    var ready: Bool
    var nwProtocol: ClientNWProtocol
    var ip: String
    var port: String
    var path: String
    var connected: Bool
    var error: String?
}

struct ClientOnboarding: Codable {
    var ready: Bool
    var step: Int
}

class ClientDataModule {
    func save(_ data: ClientData) {
        let defaults = UserDefaults.standard
        defaults.set(ClientDataJSONModule().encode(data), forKey: "PMXClientData")
        print("Saved ClientData")
    }
    
    func load() -> ClientData? {
        let defaults = UserDefaults.standard
        let clientData = ClientDataJSONModule().decode(defaults.string(forKey: "PMXClientData") ?? "")
        print("Loaded ClientData")
        return clientData
    }
}

class ClientDataJSONModule {
    func encode(_ data: ClientData) -> String? {
        let encoder = JSONEncoder()
        if let json = try? encoder.encode(data) {
            return String(data: json, encoding: .utf8)
        } else {
            print("Error encoding ClientData")
            return nil
        }
    }
    
    func decode(_ string: String) -> ClientData? {
        guard let data = string.data(using: .utf8) else {
            print("Couldn't convert received message to data")
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let packetData = try decoder.decode(ClientData.self, from: data)
            return packetData
        } catch {
            print("Error decoding ClientData: \(error)")
            return nil
        }
    }
}
