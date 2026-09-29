#!/bin/bash
set -e

DRIVER_VERSION="0.2.0"
PRINTER="A10a"
FILTER="/usr/lib/cups/filter/rastertoa10a"

echo "============================================"
echo " Désinstallation du pilote PeriPage A10a"
echo " Désinstalleur version $DRIVER_VERSION"
echo "============================================"
echo

# ------------------------------------------------------------
# Vérification des outils nécessaires
# ------------------------------------------------------------

if ! command -v lpstat >/dev/null 2>&1; then
    echo "Erreur : lpstat n'est pas disponible."
    echo
    echo "Installez CUPS avec :"
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
# Recherche des éléments installés
# ------------------------------------------------------------

PRINTER_INSTALLED=0
FILTER_INSTALLED=0

if lpstat -p "$PRINTER" >/dev/null 2>&1; then
    PRINTER_INSTALLED=1
fi

if [ -f "$FILTER" ]; then
    FILTER_INSTALLED=1
fi

if [ "$PRINTER_INSTALLED" -eq 0 ] && [ "$FILTER_INSTALLED" -eq 0 ]; then
    echo "Aucune installation du pilote PeriPage A10a n'a été détectée."
    echo
    echo "Aucune modification n'a été effectuée."
    exit 0
fi

echo "Éléments détectés :"
echo

if [ "$PRINTER_INSTALLED" -eq 1 ]; then
    echo "  - Imprimante CUPS : $PRINTER"
fi

if [ "$FILTER_INSTALLED" -eq 1 ]; then
    echo "  - Filtre CUPS     : $FILTER"
fi

echo
echo "Les fichiers sources du projet et le dossier versions/"
echo "ne seront pas supprimés."
echo

# ------------------------------------------------------------
# Confirmation
# ------------------------------------------------------------

read -r -p "Voulez-vous continuer la désinstallation ? [o/N] " ANSWER
echo

case "$ANSWER" in
    o|O|oui|OUI|Oui)
        ;;
    *)
        echo "Désinstallation annulée."
        exit 0
        ;;
esac

# ------------------------------------------------------------
# Suppression de la file CUPS
# ------------------------------------------------------------

if [ "$PRINTER_INSTALLED" -eq 1 ]; then
    echo "Suppression de l'imprimante CUPS..."
    sudo lpadmin -x "$PRINTER"
    echo "Imprimante CUPS supprimée : $PRINTER"
    echo
fi

# ------------------------------------------------------------
# Suppression du filtre CUPS
# ------------------------------------------------------------

if [ "$FILTER_INSTALLED" -eq 1 ]; then
    echo "Suppression du filtre CUPS..."
    sudo rm -f "$FILTER"
    echo "Filtre supprimé : $FILTER"
    echo
fi

# ------------------------------------------------------------
# Fin de la désinstallation
# ------------------------------------------------------------

echo "============================================"
echo " Désinstallation terminée avec succès."
echo "============================================"
echo
echo "Pilote      : PeriPage A10a"
echo "Version     : $DRIVER_VERSION"
echo
echo "Les fichiers du projet ont été conservés."
