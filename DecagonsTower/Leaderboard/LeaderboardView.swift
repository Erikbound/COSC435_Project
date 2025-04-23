//
//  LeaderboardView.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/22/25.
//

import SwiftUI

struct Player2: Identifiable {
    let id: String
    let name: String
    let enemyDefeated: Int
    let cardsCollected: Int
    
    static let testPlayers: [Player2] = [
        Player2(id: "1", name: "Aria", enemyDefeated: 5, cardsCollected: 12),
        Player2(id: "2", name: "Blaze", enemyDefeated: 8, cardsCollected: 15),
        Player2(id: "3", name: "Cyra", enemyDefeated: 3, cardsCollected: 9),
        Player2(id: "4", name: "Dax", enemyDefeated: 10, cardsCollected: 20),
        Player2(id: "5", name: "Eira", enemyDefeated: 7, cardsCollected: 14),
        Player2(id: "6", name: "Fynn", enemyDefeated: 2, cardsCollected: 6),
        Player2(id: "7", name: "Galen", enemyDefeated: 4, cardsCollected: 10),
        Player2(id: "8", name: "Hana", enemyDefeated: 6, cardsCollected: 13),
        Player2(id: "9", name: "Ivan", enemyDefeated: 9, cardsCollected: 17),
        Player2(id: "10", name: "Juno", enemyDefeated: 1, cardsCollected: 5)
    ]
}

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
    
    var sortedPlayers: [Player2] {
        switch leaderboardType {
        case .cardsCollected:
            Player2.testPlayers.sorted { $0.cardsCollected > $1.cardsCollected }
        case .enemiesDefeated:
            Player2.testPlayers.sorted { $0.enemyDefeated > $1.enemyDefeated }
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
                                
                                Text(player.element.name)
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
        }
    }
    
    private func scoreString(player: Player2) -> String {
        switch leaderboardType {
        case .cardsCollected: String(player.cardsCollected)
        case .enemiesDefeated: String(player.enemyDefeated)
        }
    }
}

#Preview {
    LeaderboardView()
}
