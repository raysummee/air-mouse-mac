//
//  ContentView.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 12/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectionManager = ConnectionEventManager.shared

    var body: some View {
        VStack(spacing: 20){
            Text(Constants.appName)
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(Constants.statusLabel)
                        .font(.headline)
                    Text(connectionManager.isConnected ? Constants.connectedStatus : Constants.notConnectedStatus)
                        .foregroundColor(connectionManager.isConnected ? .green : .red)
                }

                HStack {
                    Text(Constants.serviceLabel)
                        .font(.headline)
                    Text(connectionManager.isMonitoring ? Constants.serviceRunning : Constants.serviceStopped)
                        .foregroundColor(connectionManager.isMonitoring ? .green : .orange)
                }
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                Button(action: {
                    connectionManager.toggleService()
                }) {
                    Text(connectionManager.isMonitoring ? Constants.stopServiceButton : Constants.startServiceButton)
                        .frame(minWidth: Constants.buttonMinWidth)
                }
                .buttonStyle(.borderedProminent)
            }

            Text(Constants.windowDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(30)
        .frame(minWidth: Constants.windowWidth, minHeight: Constants.windowHeight)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
