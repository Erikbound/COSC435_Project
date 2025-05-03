import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    // Bool is true if won, false if lost
    let completion: (BattleResult) -> Void
    
    private let hitButton = GameViewController.button("Hit")
    private let repelButton = GameViewController.button("Repel")
    private let healingButton = GameViewController.button("Healing")
    private let laserButton = GameViewController.button("Laser")
    
    private lazy var stackView = makeStackView()
    
    private static func button(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        return button
    }
    
    init(completion: @escaping (BattleResult) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = SKView(frame: view.frame)
        view.addSubview(skView)

        let scene = GameScene(size: skView.bounds.size, showCards: showCards(_:), completion: completion)
//        let scene = CastleInteriorScene(
//            size: skView.bounds.size,
//            hasHealingCard: true,
//            showCards: showCards
//        )
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        setUpLayout()
        
        hitButton.addTarget(self, action: #selector(hitButtonPressed), for: .touchUpInside)
        repelButton.addTarget(self, action: #selector(repelButtonPressed), for: .touchUpInside)
        healingButton.addTarget(self, action: #selector(healingButtonPressed), for: .touchUpInside)
        laserButton.addTarget(self, action: #selector(laserButtonPressed), for: .touchUpInside)
    }
    
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [hitButton, repelButton, healingButton, laserButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        stackView.isHidden = true
        return stackView
    }
    
    private func setUpLayout() {
        view.addSubview(stackView)
        
        stackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func showCards(_ shouldShow: Bool) {
        stackView.isHidden = !shouldShow
        stackView.isUserInteractionEnabled = !shouldShow
    }
    
    @objc
    private func hitButtonPressed() {
        print(#function)
    }
    
    @objc
    private func repelButtonPressed() {
        print(#function)
    }
    
    @objc
    private func healingButtonPressed() {
        print(#function)
    }
    
    @objc
    private func laserButtonPressed() {
        print(#function)
    }
}
