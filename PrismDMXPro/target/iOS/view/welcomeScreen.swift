//
//  welcomeScreen.swift
//  PrismDMXPro
//
//  Created by Christian on 31.05.24.
//

import Foundation
import SwiftUI

struct WelcomingScreen: View {
    var body: some View {
        ZStack {
            Image("myImage")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
            Text("Welcome to the bright-side!")
                .font(.system(size: 60, weight: .semibold, design: .default))
        }
    }
}
