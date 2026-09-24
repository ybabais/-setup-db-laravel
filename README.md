# setup-db-laravel

Script qui crée automatiquement une base de données MySQL et un utilisateur
dédié pour un projet Laravel, puis met à jour le fichier `.env` du projet.

## Ce que fait le script

1. Détecte le nom du **dossier parent** du projet Laravel (celui juste
   au-dessus du dossier dans lequel tu lances la commande).
2. Utilise ce nom (nettoyé : minuscules, sans espaces/accents) comme :
   - nom de la base de données
   - nom de l'utilisateur MySQL
3. Crée la base de données si elle n'existe pas déjà.
4. Crée l'utilisateur MySQL avec le mot de passe `pwsio`, s'il n'existe pas
   déjà.
5. Donne à cet utilisateur **tous les droits, mais uniquement sur cette
   base de données** (aucun accès aux autres bases du serveur).
6. Met à jour (ou crée si absent, à partir de `.env.example`) le fichier
   `.env` du projet avec les bonnes valeurs `DB_*`.
7. Vide le cache de configuration Laravel (`php artisan config:clear`)
   pour que les changements soient pris en compte immédiatement.

## Exemple

Si ton projet Laravel se trouve dans :

```
~/projets/Alison/ali-api
```

Alors le dossier parent est `Alison`, donc le script créera :

- Base de données : `alison`
- Utilisateur MySQL : `alison`
- Mot de passe : `pwsio`

Et écrira dans `~/projets/Alison/ali-api/.env` :

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=alison
DB_USERNAME=alison
DB_PASSWORD=pwsio
```

## Prérequis

- MySQL ou MariaDB installé et démarré sur la machine.
- Accès `sudo` (le script utilise `sudo mysql -u root` pour se connecter
  en administrateur).
- Être placé dans un dossier contenant un fichier `artisan` (racine d'un
  projet Laravel) au moment de lancer le script.

## Installation

Rends le script exécutable une fois (à faire une seule fois) :

```bash
chmod +x setup-db.sh
```

## Utilisation

Depuis la **racine de ton projet Laravel** :

```bash
/chemin/vers/setup-db-laravel/setup-db.sh
```

Astuce : tu peux aussi créer un alias dans ton `~/.bashrc` pour lancer le
script plus facilement, par exemple :

```bash
alias setup-db="/chemin/vers/setup-db-laravel/setup-db.sh"
```

Puis recharge ton shell (`source ~/.bashrc`) et lance simplement :

```bash
setup-db
```

## ⚠️ Sécurité

Le mot de passe `pwsio` est volontairement simple, pensé pour un usage en
développement local uniquement. Si ce projet est un jour déployé sur un
serveur accessible depuis l'extérieur, **change ce mot de passe** pour
quelque chose de plus robuste avant la mise en production.

Le fichier `.env` ne doit jamais être commité dans Git — vérifie qu'il est
bien listé dans ton `.gitignore` (c'est le cas par défaut dans un projet
Laravel neuf).
