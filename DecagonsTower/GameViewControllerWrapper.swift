//
//  GameViewControllerWrapper.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/23/25.
//


import SwiftUI

struct GameViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController()
    }

    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        // No update needed
    }
}
