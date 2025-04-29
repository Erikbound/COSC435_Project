//
//  LeaderboardView.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/22/25.
//

import SwiftUI

struct LeaderboardView: View {
    private enum LeaderboardType: CaseIterable, Identifiable {
        case cardsCollected, enemiesDefeated
        
        var id: String { title }
        
        var title: String {
            switch self {
            case .cardsCollected: "Cards Collected"
            case .enemiesDefeated:  "Enemies Defeated"
            }
        }
    }
    
    @State private var leaderboardType: LeaderboardType = .cardsCollected
    @State private var players: [DTUser] = []
    
    var sortedPlayers: [DTUser] {
        switch leaderboardType {
        case .cardsCollected:
            players.sorted { $0.cardsCollected > $1.cardsCollected }
        case .enemiesDefeated:
            players.sorted { $0.enemiesDefeated > $1.enemiesDefeated }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Leaderboard Type", selection: $leaderboardType) {
                    ForEach(LeaderboardType.allCases) { type in
                        Text(type.title)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                
                ScrollView {
                    VStack {
                        ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { player in
                            HStack(spacing: 10) {
                                Text(String(player.offset + 1))
                                    .font(.title3)
                                    .bold()
                                    .frame(width: 30, alignment: .leading)
                                
                                Text(player.element.username)
                                    .font(.title)
                                    .frame(maxWidth: .infinity, alignment :.leading)

                                Text(scoreString(player: player.element))
                                    .font(.title)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
            .navigationTitle("Leaderboard")
            .task {
                do {
                    let allPlayers =  try await Database.fetchPlayers()
                    await MainActor.run {
                        players = allPlayers
                    }
                } catch {
                    print(error.localizedDescription)
                    print(error)
                    #warning("TODO - show error")
                }
            }
            .animation(.default, value: leaderboardType)
        }
    }
    
    private func scoreString(player: DTUser) -> String {
        switch leaderboardType {
        case .cardsCollected: String(player.cardsCollected)
        case .enemiesDefeated: String(player.enemiesDefeated)
        }
    }
}
