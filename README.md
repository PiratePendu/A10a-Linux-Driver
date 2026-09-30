# PeriPage A10a Linux Driver

Experimental CUPS driver for the **PeriPage A10a** thermal printer on Linux.

Current version: **0.5.1**

**English | [Français](README.fr.md)**

## Project Status

The driver has been developed and tested on Ubuntu with a real PeriPage A10a printer.

Validated features:

- USB printing;
- Bluetooth SPP printing;
- US Letter 8.5 × 11 in and A4 210 × 297 mm paper sizes;
- 203 dpi resolution;
- print density adjustment;
- horizontal alignment;
- paper feed offset adjustment;
- Stock and Perforated media modes;
- localized installation and uninstallation scripts;
- automatic language selection from the system environment;
- automatic fallback to English when the system language is not available.

Version **0.5.1** has been successfully tested with both USB and Bluetooth printing.

## Languages

The installation and uninstallation scripts are available in the following languages:

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

Translations are stored in the `locales/` directory.

## Installation

The installer is currently intended primarily for Ubuntu/Debian systems using CUPS.

Required packages:

    sudo apt install build-essential cups bluez bluez-cups

To install:

    chmod +x install.sh uninstall.sh
    ./install.sh

The installer automatically compiles `rastertolabel-linux.c` and installs the CUPS filter.

The USB printer queue is created as:

    A10a

If an A10a Bluetooth printer already known to the system is detected, the following queue is also created:

    A10a-Bluetooth

## Bluetooth

The printer must already be paired with the system.

The driver uses the Bluetooth Serial Port Profile (SPP) through the CUPS backend provided by `bluez-cups`.

No Bluetooth MAC address specific to an individual printer is stored in the driver.

## Uninstallation

    ./uninstall.sh

The script removes the A10a CUPS queues and the installed filter without deleting the project files.

A confirmation is requested before uninstallation. Yes/no responses are adapted to the selected language.

## Versions

Published versions of the driver are preserved in the `versions/` directory and identified by Git tags.

- 0.1.0: first archived version
- 0.2.0: detection/update and uninstallation
- 0.3.0: correct full-page Letter/A4 support
- 0.3.1: lateral safety margins
- 0.4.0: Bluetooth support
- 0.5.0: English and French localization
- 0.5.1: localization extended to 11 languages

## Compatibility

The driver has been validated on Ubuntu.

It may be adaptable to other Linux distributions using CUPS, but the current installer uses `apt` and paths specific to Debian/Ubuntu systems. Compatibility with all Linux distributions is therefore not guaranteed.

CUPS also reports that traditional PPD-based printer drivers are deprecated and may no longer be supported in a future version of CUPS.

## Main Files

- `rastertolabel-linux.c`: printer filter
- `A10a-linux-minimal.ppd`: CUPS printer description
- `install.sh`: installation script
- `uninstall.sh`: uninstallation script
- `locales/`: translation catalogs
- `versions/`: archived versions

## Status

Experimental project developed through testing with a real PeriPage A10a printer.

Version **0.5.1** is currently the stable tested version of the project.