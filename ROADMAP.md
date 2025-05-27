# Feuille de route - Prompty

## Description du projet

Prompty est une application macOS native qui aide les utilisateurs à améliorer leurs prompts. L'application prend un prompt initial et génère trois versions améliorées dans différents styles.

## Phases de développement

### Phase 1 - Interface utilisateur de base (2-3 semaines)

- [x] Configuration initiale du projet
- [ ] Interface principale :
  - Zone de saisie du prompt initial
  - 3 zones de résultats pour les différents styles
  - Bouton d'amélioration
- [ ] Thème cohérent avec macOS
- [ ] Utilisation de [tray_manager](https://github.com/leanflutter/tray_manager) pour l'icône de la barre de menu
- [ ] Utilisation de [window_manager](https://github.com/leanflutter/window_manager) pour la gestion des fenêtres(bordure, taille, position, etc.):
  - Fenêtre principale avec bordure et taille personnalisées
  - Positionnement de la fenêtre sous la barre de menu et sans bordures pour look popup
  - Gestion des événements de fermeture mcp de minimisation

- [ ] Utilisation de la plupart des packages de [LeanFlutter](https://github.com/leanflutter) pour l'implémentation des fonctionnalités de base :
    - Barre de menu
    - Gestion des fenêtres
    - Notifications natives
    - Gestion du presse-papiers

### Phase 2 - Logique métier (3-4 semaines)

- [ ] Implémentation des trois styles d'amélioration :
  - Style professionnel/formel
  - Style créatif/brainstorming
  - Style technique/structuré
- [ ] Intégration d'un service d'API pour l'amélioration des prompts
- [ ] Gestion des erreurs et des états de c&hargement

### Phase 3 - Fonctionnalités avancées (2-3 semaines)

- [ ] Historique des prompts améliorés
- [ ] Système de favoris
- [ ] Export des résultats
- [ ] Raccourcis clavier

### Phase 4 - Polissage et distribution (2 semaines)

- [ ] Tests approfondis
- [ ] Optimisations de performance
- [ ] Préparation pour le Mac App Store
- [ ] Documentation utilisateur

## Prochaines étapes

1. Mise en place de l'interface utilisateur de base
2. Configuration de l'architecture du projet
3. Implémentation des premiers composants d'interface
