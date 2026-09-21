# Performance Module

- **Qu'est-ce que c'est:** Un module LinuxServerHealthCheck, créé par [Miguel Páramos](https://www.miguelparamos.com).
- **Auteur:** [Miguel Páramos](https://www.miguelparamos.com)

## Description
Surveille et enregistre les mesures de performance du système en temps réel, notamment la température du processeur, du GPU, la charge du système (moyenne sur 1 minute) et l'utilisation de la RAM. Maintient un historique pour fournir les valeurs minimales, moyennes et maximales depuis le dernier audit.

## Vérification
**Pourquoi ceci est un module LinuxServerHealthCheck valide :**
Ce module adhère strictement à l'architecture de LinuxServerHealthCheck. Il fournit le script `module.sh` requis pour extraire les données, un modèle `template.html` pour la présentation et des scripts SQL/collecte isolés si nécessaire. Il respecte la conception décentralisée, garantissant qu'il peut être chargé dynamiquement ou désinstallé proprement sans affecter le système central.

## Licence
Ce module est distribué sous la licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
