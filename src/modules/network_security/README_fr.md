# Network Security Module

- **Qu'est-ce que c'est:** Un module LinuxServerHealthCheck, créé par [Miguel Páramos](https://www.miguelparamos.com).
- **Auteur:** [Miguel Páramos](https://www.miguelparamos.com)

## Description
Surveille la surface d'attaque du réseau en répertoriant tous les ports d'écoute exposés et en mettant en évidence ceux non autorisés. Analyse également les journaux d'authentification SSH pour compter les connexions réussies et détecter les tentatives d'attaque par force brute.

## Vérification
**Pourquoi ceci est un module LinuxServerHealthCheck valide :**
Ce module adhère strictement à l'architecture de LinuxServerHealthCheck. Il fournit le script `module.sh` requis pour extraire les données, un modèle `template.html` pour la présentation et des scripts SQL/collecte isolés si nécessaire. Il respecte la conception décentralisée, garantissant qu'il peut être chargé dynamiquement ou désinstallé proprement sans affecter le système central.

## Licence
Ce module est distribué sous la licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
