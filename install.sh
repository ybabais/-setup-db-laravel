#!/bin/bash
set -euo pipefail

# ==========================================================
# install.sh
# Télécharge setup-db.sh depuis le repo GitHub et l'installe
# globalement sur la machine, sous la commande "setup-db".
#
# Usage (sur n'importe quelle machine) :
#   curl -sL https://raw.githubusercontent.com/<TON_PSEUDO>/<TON_REPO>/main/install.sh | bash
# ==========================================================

# ⚠️ Remplace cette URL par celle de ton propre repo une fois en ligne
RAW_URL="https://raw.githubusercontent.com/<TON_PSEUDO>/<TON_REPO>/main/setup-db.sh"

DEST="/usr/local/bin/setup-db"

echo "Téléchargement du script depuis :"
echo "  $RAW_URL"

TMP_FILE="$(mktemp)"
curl -fsSL "$RAW_URL" -o "$TMP_FILE"

echo "Installation dans $DEST (sudo requis)..."
sudo mv "$TMP_FILE" "$DEST"
sudo chmod +x "$DEST"

echo ""
echo "Installé avec succès !"
echo "Depuis n'importe quel projet Laravel, lance simplement :"
echo "  setup-db"
