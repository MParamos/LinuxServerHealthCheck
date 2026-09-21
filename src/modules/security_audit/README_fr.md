# Security Audit Module

- **Qu'est-ce que c'est:** Un module LinuxServerHealthCheck, créé par [Miguel Páramos](https://www.miguelparamos.com).
- **Auteur:** [Miguel Páramos](https://www.miguelparamos.com)

## Description
S'intègre à Lynis pour effectuer un audit de sécurité rigoureux du système. Exécute des tests automatisés pour évaluer les défenses de sécurité, identifier les mauvaises configurations et résumer le nombre d'avertissements et de suggestions d'action.

## Vérification
**Pourquoi ceci est un module LinuxServerHealthCheck valide :**
Ce module adhère strictement à l'architecture de LinuxServerHealthCheck. Il fournit le script `module.sh` requis pour extraire les données, un modèle `template.html` pour la présentation et des scripts SQL/collecte isolés si nécessaire. Il respecte la conception décentralisée, garantissant qu'il peut être chargé dynamiquement ou désinstallé proprement sans affecter le système central.

## Licence
Ce module est distribué sous la licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
