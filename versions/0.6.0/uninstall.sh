#!/bin/bash
set -e

DRIVER_VERSION="0.6.0"
PRINTER="A10a"
BT_PRINTER="A10a-Bluetooth"
FILTER="/usr/lib/cups/filter/rastertoa10a"

# ------------------------------------------------------------
# Langue / traductions
# ------------------------------------------------------------

DRIVER_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCALES_DIR="$DRIVER_DIR/locales"

LANG_CODE="${LANG:-en}"
LANG_CODE="${LANG_CODE%%.*}"
LANG_CODE="${LANG_CODE%%_*}"
LANG_CODE="${LANG_CODE,,}"

# L'anglais est la langue de secours.
MESSAGES_FILE="$LOCALES_DIR/messages.$LANG_CODE"

if [ ! -f "$MESSAGES_FILE" ]; then
    MESSAGES_FILE="$LOCALES_DIR/messages.en"
fi

if [ ! -f "$MESSAGES_FILE" ]; then
    echo "Error: translation file messages.en not found."
    exit 1
fi

source "$MESSAGES_FILE"

echo "============================================"
echo " $UNINSTALL_TITLE"
echo " $UNINSTALLER_LABEL $DRIVER_VERSION"
echo "============================================"
echo

# ------------------------------------------------------------
# Vérification des outils nécessaires
# ------------------------------------------------------------

if ! command -v lpstat >/dev/null 2>&1; then
    echo "$ERROR_PREFIX : $LPSTAT_NOT_AVAILABLE"
    echo
    echo "$INSTALL_CUPS_WITH"
    echo "  sudo apt install cups"
    exit 1
fi

if ! command -v lpadmin >/dev/null 2>&1; then
    echo "$ERROR_PREFIX : $LPADMIN_NOT_AVAILABLE"
    echo
    echo "$INSTALL_CUPS_WITH"
    echo "  sudo apt install cups"
    exit 1
fi

# ------------------------------------------------------------
# Recherche des éléments installés
# ------------------------------------------------------------

PRINTER_INSTALLED=0
BT_PRINTER_INSTALLED=0
FILTER_INSTALLED=0

if lpstat -p "$PRINTER" >/dev/null 2>&1; then
    PRINTER_INSTALLED=1
fi
if lpstat -p "$BT_PRINTER" >/dev/null 2>&1; then
    BT_PRINTER_INSTALLED=1
fi


if [ -f "$FILTER" ]; then
    FILTER_INSTALLED=1
fi

if [ "$PRINTER_INSTALLED" -eq 0 ] && [ "$BT_PRINTER_INSTALLED" -eq 0 ] && [ "$FILTER_INSTALLED" -eq 0 ]; then
    echo "$NO_INSTALLATION"
    echo
    echo "$NO_MODIFICATION"
    exit 0
fi

echo "$DETECTED_ELEMENTS"
echo

if [ "$PRINTER_INSTALLED" -eq 1 ]; then
    echo "  - $CUPS_PRINTER : $PRINTER"
fi
if [ "$BT_PRINTER_INSTALLED" -eq 1 ]; then
    echo "  - $CUPS_PRINTER : $BT_PRINTER"
fi


if [ "$FILTER_INSTALLED" -eq 1 ]; then
    echo "  - $CUPS_FILTER : $FILTER"
fi

echo
echo "$PROJECT_FILES_NOTICE"

echo

# ------------------------------------------------------------
# Confirmation
# ------------------------------------------------------------

read -r -p "$CONFIRM_UNINSTALL [$CONFIRM_YES_KEY/${CONFIRM_NO_KEY^^}] " ANSWER
echo

case "${ANSWER,,}" in
    "$CONFIRM_YES_KEY"|"$CONFIRM_YES_WORD")
        ;;
    "$CONFIRM_NO_KEY"|"$CONFIRM_NO_WORD"|"")
        echo "$UNINSTALL_CANCELLED"
        exit 0
        ;;
    *)
        echo "$UNINSTALL_CANCELLED"
        exit 0
        ;;
esac

# ------------------------------------------------------------
# Suppression de la file CUPS
# ------------------------------------------------------------

if [ "$PRINTER_INSTALLED" -eq 1 ]; then
    echo "$REMOVING_PRINTER"
    sudo lpadmin -x "$PRINTER"
    echo "$PRINTER_REMOVED : $PRINTER"
    echo
fi

# ------------------------------------------------------------
if [ "$BT_PRINTER_INSTALLED" -eq 1 ]; then
    echo "$REMOVING_BT_PRINTER"
    sudo lpadmin -x "$BT_PRINTER"
    echo "$BT_PRINTER_REMOVED : $BT_PRINTER"
    echo
fi

# ------------------------------------------------------------

# Suppression du filtre CUPS
# ------------------------------------------------------------

if [ "$FILTER_INSTALLED" -eq 1 ]; then
    echo "$REMOVING_FILTER"
    sudo rm -f "$FILTER"
    echo "$FILTER_REMOVED : $FILTER"
    echo
fi

# ------------------------------------------------------------
# Fin de la désinstallation
# ------------------------------------------------------------

echo "============================================"
echo " $UNINSTALL_COMPLETE"
echo "============================================"
echo
echo "$DRIVER_LABEL      : PeriPage A10a"
echo "$VERSION_LABEL     : $DRIVER_VERSION"
echo
echo "$PROJECT_FILES_KEPT"
