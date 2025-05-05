//
//  GameOverView.swift
//  DecagonsTower
//
//  Created by Mu Mung on 5/2/25.
//

import SwiftUI

struct GameOverView: View {
    let playAgain: () -> Void
    let showLeaderboard: () -> Void
    
    let didWin: Bool
    let cardsCount: Int
    
    private var resultString: String {
        if didWin {
            "You defeated the knight and won \(cardsCount) cards!"
        } else {
            "You were defeated!"
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Game Over")
                    .font(.largeTitle)
                    .foregroundStyle(Color.white)
                    .bold()
                    .shadow(color: Color.red, radius: 15.0)
                    .shadow(color: Color.red, radius: 15.0)
                    .shadow(color: Color.red, radius: 15.0)
                    .shadow(color: Color.red, radius: 15.0)
                    .padding(.top, 50)
                
                Text(resultString)
                    .font(.title2)
                    .foregroundStyle(Color.white)
                    .bold()
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.red, radius: 5.0)
                    .shadow(color: Color.red, radius: 5.0)
                    .shadow(color: Color.red, radius: 5.0)
                    .shadow(color: Color.red, radius: 5.0)
                
                Button(action: playAgain) {
                    Text("Play Again")
                        .foregroundStyle(Color.white)
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
                .padding(.top, 20)
                
                Button(action: showLeaderboard) {
                    Text("Leaderboard")
                        .foregroundStyle(Color.white)
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
                .padding(.top, 10)
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Image("InsideCastle") // Change this to change background image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .ignoresSafeArea(.all)
        }
    }
}
