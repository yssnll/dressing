# SmartWardrobe

MVP iPhone en **SwiftUI** pour transformer le dressing de l'utilisateur en styliste personnel.

## Fonctionnalités incluses

- Dressing local persistant avec vêtements de démonstration.
- Ajout d'un vêtement depuis la photothèque avec `PhotosPicker`.
- Fiche vêtement : catégorie, couleur, matière, style, saison et niveau de formalité.
- Planificateur de destination : ville, date, horaires et contexte.
- Météo locale de démonstration, sans clé API, avec prévision matin/après-midi/soir.
- Génération de trois tenues uniquement à partir des pièces du dressing.
- Filtres de contexte : quotidien, travail, soirée, sport, voyage et événement.
- Actions “Je n'aime pas” et “Plus élégant”.
- Stockage local via `UserDefaults` + `Codable`.

## Ouvrir dans Xcode

1. Ouvre `SmartWardrobe.xcodeproj`.
2. Choisis une équipe de signature dans **Signing & Capabilities**.
3. Sélectionne un simulateur iPhone ou un appareil connecté.
4. Lance avec `⌘R`.

Le projet cible iOS 17.0 et ne dépend d'aucun package externe.

## Brancher une vraie météo

Le MVP embarque `DemoWeatherService` pour être immédiatement testable. Pour brancher une API météo, remplace l'implémentation dans `Services/WeatherService.swift` en conservant le protocole `WeatherService`.

## Génération d'une IPA

Depuis Xcode :

1. `Product > Archive`
2. Dans Organizer, `Distribute App`
3. Choisis une méthode de distribution (Ad Hoc, Development ou App Store Connect)

Pour une IPA installable sur un appareil réel, il faut un compte Apple Developer et une signature valide.