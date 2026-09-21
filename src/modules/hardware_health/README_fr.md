# Hardware Health Module

- **Qu'est-ce que c'est:** Un module LinuxServerHealthCheck, créé par [Miguel Páramos](https://www.miguelparamos.com).
- **Auteur:** [Miguel Páramos](https://www.miguelparamos.com)

## Description
Effectue une analyse matérielle approfondie à l'aide des données S.M.A.R.T. et de `hdparm`. Lit l'état de santé de tous les disques connectés, évalue les vitesses de lecture brutes et fournit une estimation du pourcentage de durée de vie restante. Remarque : une durée de vie restante de 0 % ne signifie pas que le disque tombera immédiatement en panne, mais plutôt qu'il pourrait commencer à développer des erreurs à tout moment.

## Vérification
**Pourquoi ceci est un module LinuxServerHealthCheck valide :**
Ce module adhère strictement à l'architecture de LinuxServerHealthCheck. Il fournit le script `module.sh` requis pour extraire les données, un modèle `template.html` pour la présentation et des scripts SQL/collecte isolés si nécessaire. Il respecte la conception décentralisée, garantissant qu'il peut être chargé dynamiquement ou désinstallé proprement sans affecter le système central.

## Licence
Ce module est distribué sous la licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
