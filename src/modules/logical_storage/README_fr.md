# Logical Storage Module

- **Qu'est-ce que c'est:** Un module LinuxServerHealthCheck, créé par [Miguel Páramos](https://www.miguelparamos.com).
- **Auteur:** [Miguel Páramos](https://www.miguelparamos.com)

## Description
Analyse toutes les partitions logiques montées (`/dev/*`). Fournit des statistiques d'utilisation du stockage en temps réel et met en évidence les seuils critiques. Analyse également l'hôte pour trouver les 5 dossiers les plus lourds à la racine, les 5 fichiers les plus lourds globalement et les 5 fichiers les plus récemment modifiés.

## Vérification
**Pourquoi ceci est un module LinuxServerHealthCheck valide :**
Ce module adhère strictement à l'architecture de LinuxServerHealthCheck. Il fournit le script `module.sh` requis pour extraire les données, un modèle `template.html` pour la présentation et des scripts SQL/collecte isolés si nécessaire. Il respecte la conception décentralisée, garantissant qu'il peut être chargé dynamiquement ou désinstallé proprement sans affecter le système central.

## Licence
Ce module est distribué sous la licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
