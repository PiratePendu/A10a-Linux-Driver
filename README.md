# PeriPage A10a Linux Driver

Pilote CUPS expérimental pour l'imprimante thermique **PeriPage A10a** sous Linux.

Version actuelle : **0.4.0**

## État du projet

Le pilote a été développé et testé sous Ubuntu avec une PeriPage A10a réelle.

Fonctionnalités validées :

- impression par USB ;
- impression par Bluetooth SPP ;
- format US Letter 8.5 × 11 pouces ;
- format A4 210 × 297 mm ;
- résolution 203 dpi ;
- réglage de densité d'impression ;
- alignement horizontal ;
- décalage d'avance papier ;
- modes Stock et Perforated.

La version 0.4.0 a été testée avec succès en USB et en Bluetooth.

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

## Versions

Les anciennes versions du pilote sont conservées dans le dossier `versions/`.

- 0.1.0 : première version archivée
- 0.2.0 : détection/mise à jour et désinstallation
- 0.3.0 : prise en charge correcte des pages Letter/A4 complètes
- 0.3.1 : marges latérales de sécurité
- 0.4.0 : prise en charge Bluetooth

## Compatibilité

Le pilote a été validé sous Ubuntu.

Il peut être adaptable à d'autres distributions Linux utilisant CUPS, mais la version actuelle de l'installateur utilise notamment `apt` et des chemins propres aux systèmes Debian/Ubuntu. La compatibilité avec toutes les distributions Linux n'est donc pas garantie.

CUPS signale également que les pilotes traditionnels basés sur des fichiers PPD sont dépréciés et pourront ne plus être pris en charge dans une future version de CUPS.

## Fichiers principaux

- `rastertolabel-linux.c` : filtre d'impression
- `A10a-linux-minimal.ppd` : description CUPS de l'imprimante
- `install.sh` : installation
- `uninstall.sh` : désinstallation
- `versions/` : archives des versions précédentes

## Statut

Projet expérimental développé à partir de tests réalisés sur une PeriPage A10a réelle.

La version 0.4.0 constitue actuellement la version stable testée du projet.
