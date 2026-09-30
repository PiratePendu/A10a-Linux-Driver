# Pilote Linux pour PeriPage A10a

Pilote CUPS expérimental pour l'imprimante thermique **PeriPage A10a** sous Linux.

Version actuelle : **0.6.0**

**[English](README.md) | Français**

## État du projet

Le pilote a été développé et testé sous Ubuntu avec une PeriPage A10a réelle.

Fonctionnalités validées :

- impression par USB ;
- impression par Bluetooth SPP ;
- formats US Letter 8.5 × 11 pouces et A4 210 × 297 mm ;
- résolution 203 dpi ;
- réglage de la densité d'impression ;
- alignement horizontal ;
- décalage d'avance papier ;
- modes Stock et Perforated ;
- scripts d'installation et de désinstallation localisés ;
- sélection automatique de la langue à partir de l'environnement système ;
- repli automatique vers l'anglais lorsqu'une langue n'est pas disponible.
- Modes de tramage d'image : Threshold (par défaut) et Floyd-Steinberg

La version **0.6.0** a été testée avec succès en USB et en Bluetooth. Le mode Threshold conserve le rendu noir et blanc précédent, tandis que le tramage Floyd-Steinberg a été testé avec succès pour le rendu d'images en niveaux de gris via Bluetooth.

## Langues

Les scripts d'installation et de désinstallation sont disponibles dans les langues suivantes :

- English (`en`)
- Français (`fr`)
- Deutsch (`de`)
- Español (`es`)
- Italiano (`it`)
- Português (`pt`)
- Nederlands (`nl`)
- Polski (`pl`)
- 简体中文 (`zh`)
- 日本語 (`ja`)
- 한국어 (`ko`)

Les traductions sont stockées dans le dossier `locales/`.

## Installation

Le script d'installation est actuellement prévu principalement pour Ubuntu/Debian et utilise CUPS.

Paquets nécessaires :

    sudo apt install build-essential cups bluez bluez-cups

Pour installer :

    chmod +x install.sh uninstall.sh
    ./install.sh

Le script compile automatiquement `rastertolabel-linux.c` et installe le filtre CUPS.

La file USB créée est :

    A10a

Lorsqu'une imprimante Bluetooth A10a déjà connue du système est détectée, la file suivante est également créée :

    A10a-Bluetooth

## Bluetooth

L'imprimante doit préalablement être appairée avec le système.

Le pilote utilise le profil Bluetooth Serial Port (SPP) par l'intermédiaire du backend CUPS fourni par `bluez-cups`.

Aucune adresse MAC Bluetooth propre à une imprimante particulière n'est enregistrée dans le pilote.

## Désinstallation

    ./uninstall.sh

Le script supprime les files CUPS A10a ainsi que le filtre installé, sans supprimer les fichiers du projet.

Une confirmation est demandée avant la désinstallation. Les réponses oui/non sont adaptées à la langue sélectionnée.

## Versions

Les versions publiées du pilote sont conservées dans le dossier `versions/` et identifiées par des tags Git.

- 0.1.0 : première version archivée
- 0.2.0 : détection/mise à jour et désinstallation
- 0.3.0 : prise en charge correcte des pages Letter/A4 complètes
- 0.3.1 : marges latérales de sécurité
- 0.4.0 : prise en charge Bluetooth
- 0.5.0 : ajout de la localisation française et anglaise
- 0.5.1 : localisation étendue à 11 langues
- 0.6.0 : ajout du tramage Floyd-Steinberg pour le rendu d'images en niveaux de gris

## Compatibilité

Le pilote a été validé sous Ubuntu.

Il peut être adaptable à d'autres distributions Linux utilisant CUPS, mais la version actuelle de l'installateur utilise notamment `apt` et des chemins propres aux systèmes Debian/Ubuntu. La compatibilité avec toutes les distributions Linux n'est donc pas garantie.

CUPS signale également que les pilotes traditionnels basés sur des fichiers PPD sont dépréciés et pourront ne plus être pris en charge dans une future version de CUPS.

## Fichiers principaux

- `rastertolabel-linux.c` : filtre d'impression
- `A10a-linux-minimal.ppd` : description CUPS de l'imprimante
- `install.sh` : installation
- `uninstall.sh` : désinstallation
- `locales/` : catalogues de traduction
- `versions/` : archives des versions précédentes

## Licence

Ce projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).

Cette licence s'applique également au code source contenu dans les versions archivées sous `versions/`, y compris aux versions publiées avant l'ajout du fichier `LICENSE` au dépôt.

## Statut

Projet expérimental développé à partir de tests réalisés sur une PeriPage A10a réelle.

La version **0.6.0** constitue actuellement la version stable testée du projet.