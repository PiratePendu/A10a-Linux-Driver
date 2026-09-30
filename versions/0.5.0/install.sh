#!/bin/bash
set -e

DRIVER_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$DRIVER_DIR/rastertolabel-linux.c"
PPD="$DRIVER_DIR/A10a-linux-minimal.ppd"
FILTER="/usr/lib/cups/filter/rastertoa10a"
PRINTER="A10a"
BT_PRINTER="A10a-Bluetooth"
DRIVER_VERSION="0.5.0"

# ------------------------------------------------------------
# Langue / traductions
# ------------------------------------------------------------

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
echo " $INSTALL_TITLE"
echo " version $DRIVER_VERSION"
echo "============================================"
echo

# ------------------------------------------------------------
# Vérification des fichiers nécessaires
# ------------------------------------------------------------

if [ ! -f "$SOURCE" ]; then
    echo "$ERROR_PREFIX : $SOURCE_NOT_FOUND"
    exit 1
fi

if [ ! -f "$PPD" ]; then
    echo "$ERROR_PREFIX : $PPD_NOT_FOUND"
    exit 1
fi

# ------------------------------------------------------------
# Vérification des outils nécessaires
# ------------------------------------------------------------

if ! command -v gcc >/dev/null 2>&1; then
    echo "$ERROR_PREFIX : $GCC_NOT_INSTALLED"
    echo
    echo "$INSTALL_WITH"
    echo "  sudo apt install build-essential"
    exit 1
fi

if ! command -v lpinfo >/dev/null 2>&1; then
    echo "$ERROR_PREFIX : $CUPS_NOT_INSTALLED"
    echo
    echo "$INSTALL_WITH"
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

if ! command -v lpstat >/dev/null 2>&1; then
    echo "$ERROR_PREFIX : $LPSTAT_NOT_AVAILABLE"
    echo
    echo "$INSTALL_CUPS_WITH"
    echo "  sudo apt install cups"
    exit 1
fi


if ! command -v bluetoothctl >/dev/null 2>&1; then
    echo "$ERROR_PREFIX : $BLUETOOTHCTL_NOT_INSTALLED"
    echo
    echo "$INSTALL_WITH"
    echo "  sudo apt install bluez"
    exit 1
fi
if [ ! -x /usr/lib/cups/backend/bluetooth ]; then
    echo "$ERROR_PREFIX : $BLUETOOTH_BACKEND_NOT_INSTALLED"
    echo
    echo "$INSTALL_WITH"
    echo "  sudo apt install bluez-cups"
    exit 1
fi



# Recherche d'une installation existante
# ------------------------------------------------------------

echo "$SEARCHING_EXISTING"

if lpstat -p "$PRINTER" >/dev/null 2>&1; then
    UPDATE=1
    echo "$EXISTING_INSTALLATION : $PRINTER"
    echo "$DRIVER_WILL_UPDATE"
else
    UPDATE=0
    echo "$NO_EXISTING_INSTALLATION"
    echo "$NEW_INSTALLATION"
fi

echo

# ------------------------------------------------------------
# Préparation de l'imprimante
# ------------------------------------------------------------

echo "$PREPARE_PRINTER"
echo
echo "  $PREPARE_1"
echo "  $PREPARE_2"
echo "  $PREPARE_3"
echo "  $PREPARE_4"
echo

read -r -p "$PRESS_ENTER_READY"
echo

# ------------------------------------------------------------
# Détection automatique de la PeriPage A10a
# ------------------------------------------------------------

while true; do

    echo "$SEARCHING_PRINTER"

    URI="$(lpinfo -v 2>/dev/null | \
        awk '/usb:\/\/\/A10a(\?|$)/ {print $2; exit}')"

    if [ -n "$URI" ]; then
        echo "$PRINTER_DETECTED : $URI"
        echo
        break
    fi

    echo
    echo "$NO_PRINTER"
    echo
    echo "$CHECK_THAT"
    echo "  - $CHECK_POWER"
    echo "  - $CHECK_USB"
    echo "  - $CHECK_CONNECTED"
    echo
    echo "$PRESS_ENTER_RETRY"
    echo "$CTRL_C_CANCEL"
    echo

    read -r
    echo

done

# ------------------------------------------------------------
# Détection Bluetooth de la PeriPage A10a
BT_MAC="$(bluetoothctl devices 2>/dev/null | awk '$3 ~ /^A10a_/ {print $2; exit}')"

if [ -n "$BT_MAC" ]; then
    BT_ID="${BT_MAC//:/}"
    BT_URI="bluetooth://${BT_ID}/spp"
    echo "$BT_PRINTER_DETECTED : $BT_MAC"
    echo "$BT_CONNECTION : $BT_URI"
else
    BT_URI=""
    echo "$NO_BT_PRINTER"
fi
echo

# ------------------------------------------------------------


# Compilation du filtre CUPS
# ------------------------------------------------------------

echo "$COMPILING_DRIVER"

gcc -Wall -O2 \
    -o "$DRIVER_DIR/rastertolabel-linux" \
    "$SOURCE" \
    -lcups

echo "$COMPILATION_SUCCESS"
echo

# ------------------------------------------------------------
# Installation du filtre CUPS
# ------------------------------------------------------------

echo "$INSTALLING_FILTER"

sudo cp "$DRIVER_DIR/rastertolabel-linux" "$FILTER"
sudo chown root:root "$FILTER"
sudo chmod 755 "$FILTER"

echo "$FILTER_INSTALLED : $FILTER"
echo

# ------------------------------------------------------------
# Création / mise à jour de la file CUPS
# ------------------------------------------------------------

echo "$CONFIGURING_CUPS"

sudo lpadmin \
    -p "$PRINTER" \
    -E \
    -v "$URI" \
    -P "$PPD"

echo

# ------------------------------------------------------------
# Création / mise à jour de la file CUPS Bluetooth
# ------------------------------------------------------------
if [ -n "$BT_URI" ]; then
    echo "$CONFIGURING_BLUETOOTH"
    sudo lpadmin \
        -p "$BT_PRINTER" \
        -E \
        -v "$BT_URI" \
        -P "$PPD"
    echo "$BT_QUEUE_CONFIGURED : $BT_PRINTER"
    echo
fi

# ------------------------------------------------------------
# Fin de l'installation
# ------------------------------------------------------------

echo "============================================"

if [ "$UPDATE" -eq 1 ]; then
    echo " $UPDATE_COMPLETE"
else
    echo " $INSTALL_COMPLETE"
fi

echo "============================================"
echo
echo "$DRIVER_LABEL      : PeriPage A10a"
echo "$VERSION_LABEL     : $DRIVER_VERSION"
echo "$PRINTER_LABEL  : $PRINTER"
echo "$CONNECTION_LABEL   : $URI"
echo
echo "$NO_TEST_PRINT"
