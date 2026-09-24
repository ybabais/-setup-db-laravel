#!/bin/bash
set -uo pipefail

# ==========================================================
# setup-db.sh
# Crée automatiquement une base de données MySQL + un
# utilisateur dédié pour un projet Laravel, et met à jour
# le fichier .env du projet en conséquence.
#
# Nom de la BDD / de l'utilisateur = nom du dossier PARENT
# du projet Laravel (celui juste au-dessus du dossier
# courant).
# Mot de passe utilisateur = pwsio
#
# Usage : à lancer depuis la RACINE du projet Laravel
#   ./setup-db.sh
# ==========================================================

PROJECT_DIR="$(pwd)"
PARENT_NAME="$(basename "$(dirname "$PROJECT_DIR")")"
DB_NAME=$(echo "$PARENT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g')
DB_USER="$DB_NAME"
DB_PASS="pwsio"

IS_LARAVEL=false
[ -f "artisan" ] && IS_LARAVEL=true

# ----------------------------------------------------------
# Met à jour (ou ajoute) une variable dans le .env,
# que la ligne soit commentée ou non.
# Usage : set_env_var CLE valeur
# ----------------------------------------------------------
set_env_var() {
  local key="$1"
  local value="$2"
  local file=".env"

  if grep -qE "^#*[[:space:]]*${key}=" "$file"; then
    sed -i -E "s|^#*[[:space:]]*${key}=.*|${key}=${value}|" "$file"
  else
    echo "${key}=${value}" >> "$file"
  fi
}

update_env() {
  if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
      cp .env.example .env
    else
      echo "Aucun .env ni .env.example trouvé, impossible de continuer."
      return 1
    fi
  fi

  set_env_var "DB_CONNECTION" "mysql"
  set_env_var "DB_HOST" "127.0.0.1"
  set_env_var "DB_PORT" "3306"
  set_env_var "DB_DATABASE" "${DB_NAME}"
  set_env_var "DB_USERNAME" "${DB_USER}"
  set_env_var "DB_PASSWORD" "${DB_PASS}"

  # Locale en français
  set_env_var "APP_LOCALE" "fr"
  set_env_var "APP_FALLBACK_LOCALE" "fr"
  set_env_var "APP_FAKER_LOCALE" "fr_FR"

  echo "Fichier .env mis à jour (DB + locale FR)."

  if [ "$IS_LARAVEL" = true ] && command -v php >/dev/null 2>&1; then
    php artisan config:clear >/dev/null 2>&1 || true
  fi
}

create_db() {
  echo "Création de la base '${DB_NAME}' et de l'utilisateur '${DB_USER}'..."
  sudo mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF
  echo "Base de données et utilisateur créés."
}

delete_db() {
  echo "Suppression de la base '${DB_NAME}' et de l'utilisateur '${DB_USER}'..."
  sudo mysql -u root <<EOF
DROP DATABASE IF EXISTS \`${DB_NAME}\`;
DROP USER IF EXISTS '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF
  echo "Base de données et utilisateur supprimés."
}

run_setup() {
  create_db
  if [ "$IS_LARAVEL" = true ]; then
    update_env
    echo ""
    echo "Terminé ! Base '${DB_NAME}' et utilisateur '${DB_USER}' prêts, .env configuré."
  else
    echo ""
    echo "Aucun fichier 'artisan' trouvé ici : pas de projet Laravel, .env non modifié."
    echo "Infos de connexion :"
    echo "  Host     : 127.0.0.1"
    echo "  Port     : 3306"
    echo "  Database : ${DB_NAME}"
    echo "  User     : ${DB_USER}"
    echo "  Password : ${DB_PASS}"
  fi
}

run_reset() {
  delete_db
  run_setup
}

pause() {
  read -rp "Appuie sur Entrée pour continuer..." _
}

# ----------------------------------------------------------
# Menu interactif : whiptail si disponible, sinon menu texte
# ----------------------------------------------------------
main_menu() {
  echo "Nom détecté     : ${PARENT_NAME}"
  echo "Base de données : ${DB_NAME}"
  echo "Utilisateur     : ${DB_USER}"
  echo ""

  if command -v whiptail >/dev/null 2>&1; then
    CHOICE=$(whiptail --title "setup-db-laravel" \
      --menu "Base : ${DB_NAME}  |  Utilisateur : ${DB_USER}" 15 60 4 \
      "1" "Configurer (créer / mettre à jour la BDD et le .env)" \
      "2" "Supprimer la BDD et l'utilisateur" \
      "3" "Tout réinitialiser (supprimer puis recréer)" \
      "4" "Annuler / Quitter" \
      3>&1 1>&2 2>&3) || { echo "Annulé."; exit 0; }
  else
    echo "1) Configurer (créer / mettre à jour la BDD et le .env)"
    echo "2) Supprimer la BDD et l'utilisateur"
    echo "3) Tout réinitialiser (supprimer puis recréer)"
    echo "4) Annuler / Quitter"
    read -rp "Ton choix [1-4] : " CHOICE
  fi

  case "$CHOICE" in
    1) run_setup ;;
    2) delete_db ;;
    3) run_reset ;;
    4|"") echo "Annulé." ;;
    *) echo "Choix invalide." ;;
  esac
}

main_menu
