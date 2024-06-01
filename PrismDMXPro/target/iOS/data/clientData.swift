//
//  clientData.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI

///#PMX Client Data Handler
/*
 1. **Structs:**
    - `ClientNWProtocol`: An enumeration representing different network protocols (`https`, `http`, `ws`, `wss`).
    - `ClientData`: A struct representing client data, consisting of networking and onboarding information.
    - `ClientNetworking`: A struct representing networking information, including readiness, network protocol, IP address, port, path, connection status, and optional error message.
    - `ClientOnboarding`: A struct representing onboarding status, including readiness and current step.

 2. **Classes:**
    - `ClientDataModule`: A class responsible for handling the saving and loading of client data.
    - `ClientDataJSONModule`: A class responsible for encoding and decoding client data to/from JSON.

 3. **Functions:**
    - `ClientDataModule`:
      - `save(_: ClientData)`: Saves client data to UserDefaults after encoding it to JSON.
      - `load() -> ClientData?`: Loads client data from UserDefaults by decoding it from JSON.

    - `ClientDataJSONModule`:
      - `encode(_: ClientData) -> String?`: Encodes client data to a JSON string.
      - `decode(_: String) -> ClientData?`: Decodes a JSON string to client data.
 */

enum ClientNWProtocol: String, Codable, CaseIterable {
    case https
    case http
    case ws
    case wss
}

struct ClientData: Codable, Equatable {
    var networking: ClientNetworking
    var onboarding: ClientOnboarding
}

struct ClientNetworking: Codable, Equatable {
    var ready: Bool
    var nwProtocol: ClientNWProtocol
    var ip: String
    var port: String
    var path: String
    var connected: Bool
    var error: String?
}

struct ClientOnboarding: Codable, Equatable {
    var ready: Bool
    var step: Int
}

// Module responsible for handling saving and loading of client data
class ClientDataModule {
    // Method to save client data to UserDefaults
    func save(_ data: ClientData) {
        let defaults = UserDefaults.standard
        // Encode client data to JSON string and save it to UserDefaults under key "PMXClientData"
        defaults.set(ClientDataJSONModule().encode(data), forKey: "PMXClientData")
        // Print confirmation message
        print("Saved ClientData")
    }
    
    // Method to load client data from UserDefaults
    func load() -> ClientData? {
        let defaults = UserDefaults.standard
        // Retrieve JSON string from UserDefaults using key "PMXClientData" and decode it to ClientData object
        let clientData = ClientDataJSONModule().decode(defaults.string(forKey: "PMXClientData") ?? "")
        // Print confirmation message
        print("Loaded ClientData")
        // Return loaded ClientData object or nil if not found
        return clientData
    }
}

// Module responsible for encoding and decoding client data to/from JSON
class ClientDataJSONModule {
    // Method to encode client data to JSON string
    func encode(_ data: ClientData) -> String? {
        let encoder = JSONEncoder()
        // Attempt to encode client data to JSON
        if let json = try? encoder.encode(data) {
            // Convert JSON data to UTF-8 string and return
            return String(data: json, encoding: .utf8)
        } else {
            // Print error message if encoding fails
            print("Error encoding ClientData")
            return nil
        }
    }
    
    // Method to decode JSON string to client data
    func decode(_ string: String) -> ClientData? {
        // Convert JSON string to data
        guard let data = string.data(using: .utf8) else {
            // Print error message if conversion fails
            print("Couldn't convert received message to data")
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            // Attempt to decode JSON data to ClientData object
            let packetData = try decoder.decode(ClientData.self, from: data)
            return packetData
        } catch {
            // Print error message if decoding fails
            print("Error decoding ClientData: \(error)")
            return nil
        }
    }
}
