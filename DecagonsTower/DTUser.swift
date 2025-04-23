class DTUser: Codable {
    let id: String
    let email: String
    let username: String
    let enemiesDefeated: Int
    let cardsCollected: Int
    
    init(
        id: String,
        email: String,
        username: String,
        enemiesDefeated: Int = 0,
        cardsCollected: Int = 0
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.enemiesDefeated = enemiesDefeated
        self.cardsCollected = cardsCollected
    }
}