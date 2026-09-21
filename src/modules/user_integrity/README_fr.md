# User Integrity Module

- **Qu'est-ce que c'est:** Un module LinuxServerHealthCheck, créé par [Miguel Páramos](https://www.miguelparamos.com).
- **Auteur:** [Miguel Páramos](https://www.miguelparamos.com)

## Description
Analyse les comptes d'utilisateurs du système pour détecter une escalade de privilèges non autorisée. Compte le nombre d'utilisateurs de niveau root (UID 0) et répertorie tous les utilisateurs du système, y compris les services système et les comptes réguliers.

## Vérification
**Pourquoi ceci est un module LinuxServerHealthCheck valide :**
Ce module adhère strictement à l'architecture de LinuxServerHealthCheck. Il fournit le script `module.sh` requis pour extraire les données, un modèle `template.html` pour la présentation et des scripts SQL/collecte isolés si nécessaire. Il respecte la conception décentralisée, garantissant qu'il peut être chargé dynamiquement ou désinstallé proprement sans affecter le système central.

## Licence
Ce module est distribué sous la licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
