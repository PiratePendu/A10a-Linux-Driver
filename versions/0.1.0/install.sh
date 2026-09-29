#!/bin/bash
set -e

DRIVER_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$DRIVER_DIR/rastertolabel-linux.c"
PPD="$DRIVER_DIR/A10a-linux-minimal.ppd"
FILTER="/usr/lib/cups/filter/rastertoa10a"
PRINTER="A10a"
DRIVER_VERSION="0.1.0"

echo "============================================"
echo " Pilote PeriPage A10a pour Linux"
echo " Version $DRIVER_VERSION"
echo "============================================"
echo

# ------------------------------------------------------------
# Vérification des fichiers nécessaires
# ------------------------------------------------------------

if [ ! -f "$SOURCE" ]; then
    echo "Erreur : rastertolabel-linux.c introuvable."
    exit 1
fi

if [ ! -f "$PPD" ]; then
    echo "Erreur : A10a-linux-minimal.ppd introuvable."
    exit 1
fi

# ------------------------------------------------------------
# Vérification des outils nécessaires
# ------------------------------------------------------------

if ! command -v gcc >/dev/null 2>&1; then
    echo "Erreur : gcc n'est pas installé."
    echo
    echo "Installez-le avec :"
    echo "  sudo apt install build-essential"
    exit 1
fi

if ! command -v lpinfo >/dev/null 2>&1; then
    echo "Erreur : les outils CUPS ne sont pas installés."
    echo
    echo "Installez-les avec :"
    echo "  sudo apt install cups"
    exit 1
fi

if ! command -v lpadmin >/dev/null 2>&1; then
    echo "Erreur : lpadmin n'est pas disponible."
    echo
    echo "Installez CUPS avec :"
    echo "  sudo apt install cups"
    exit 1
fi

# ------------------------------------------------------------
# Préparation de l'imprimante
# ------------------------------------------------------------

echo "Préparation de l'imprimante :"
echo
echo "  1. Débranchez le câble USB de l'ordinateur."
echo "  2. Allumez la PeriPage A10a."
echo "  3. Attendez que l'imprimante soit prête."
echo "  4. Branchez ensuite le câble USB à l'ordinateur."
echo

read -r -p "Appuyez sur Entrée lorsque l'imprimante est prête..."
echo

# ------------------------------------------------------------
# Détection automatique de la PeriPage A10a
# ------------------------------------------------------------

while true; do

    echo "Recherche de l'imprimante A10a..."

    URI="$(lpinfo -v 2>/dev/null | \
        awk '/usb:\/\/\/A10a(\?|$)/ {print $2; exit}')"

    if [ -n "$URI" ]; then
        echo "A10a détectée : $URI"
        echo
        break
    fi

    echo
    echo "Aucune PeriPage A10a détectée."
    echo
    echo "Vérifiez que :"
    echo "  - l'imprimante est allumée ;"
    echo "  - le câble USB est correctement branché ;"
    echo "  - l'imprimante est connectée à l'ordinateur."
    echo
    echo "Appuyez sur Entrée pour réessayer."
    echo "Utilisez Ctrl+C pour annuler l'installation."
    echo

    read -r
    echo

done

# ------------------------------------------------------------
# Compilation du filtre CUPS
# ------------------------------------------------------------

echo "Compilation du filtre..."

gcc -Wall -O2 \
    -o "$DRIVER_DIR/rastertolabel-linux" \
    "$SOURCE" \
    -lcups

echo "Compilation réussie."
echo

# ------------------------------------------------------------
# Installation du filtre CUPS
# ------------------------------------------------------------

echo "Installation du filtre CUPS..."

sudo cp "$DRIVER_DIR/rastertolabel-linux" "$FILTER"
sudo chown root:root "$FILTER"
sudo chmod 755 "$FILTER"

echo "Filtre installé : $FILTER"
echo

# ------------------------------------------------------------
# Création / mise à jour de la file CUPS
# ------------------------------------------------------------

echo "Configuration de CUPS..."

sudo lpadmin \
    -p "$PRINTER" \
    -E \
    -v "$URI" \
    -P "$PPD"

echo

# ------------------------------------------------------------
# Fin de l'installation
# ------------------------------------------------------------

echo "============================================"
echo " Installation terminée avec succès."
echo "============================================"
echo
echo "Imprimante CUPS : $PRINTER"
echo "Connexion        : $URI"
echo
echo "Aucune impression de test n'a été envoyée."
echo
echo "Pilote      : PeriPage A10a"
echo "Version     : $DRIVER_VERSION"
echo "Imprimante  : $PRINTER"
echo "Connexion   : $URI"