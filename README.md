# Projet Administration Système 1 - Outils d'administration d'utilisateurs UNIX
## Julien Leleu - DA2I 2015/2016
## Copyright : Inspiré du README de Thomas Ferro
----------------------

### Sommaire

- Liste des fonctionnalités (TODO List)
- Documentation utilisateur
  - Ajout d'un (de plusieurs) utilisateur(s)
    - En ligne de commande
    - Depuis un fichier
  - Suppression d'un utilisateur
  - Modification des données d'un utilisateur
    - Mot de passe
    - Répertoire de travail
    - Langage de commande
- Documentation technique
  - Ajout d'un (de plusieurs) utilisateur(s)
    - En ligne de commande
    - Depuis un fichier
  - Suppression d'un utilisateur
  - Modification des données d'un utilisateur
    - Mot de passe
    - Répertoire de travail
    - Langage de commande

----------------------

### Liste des fonctionnalités (TODO List) :

- [x] Ajout utilisateur(s)
 - [x] En ligne de commande
 - [x] Depuis un fichier
- [x] Suppression utilisateur
- [x] Modification utilisateur
 - [x] Mot de passe
 - [x] Répertoire de travail
 - [x] Langage de commande

-----------------------

### Documentation utilisateur :

- #### Ajout d'un ou de plusieurs utilisateur(s) :
  La fonction de base du programme est de pouvoir ajouter des utilisateurs.
  A l'appel de la commande d'ajout, le programme demande à l'utilisateur d'entrer un nouveau mot de passe et de le confirmer.
  Vous pourrez le modifier par la suite.

  La création d'utilisateur ne fait pas qu'ajouter ce dernier au système, elle créer aussi un répertoire **/home/<login>**, copie les fichiers d'initialisation du shell.

  Voici les différentes méthodes pour créer des utilisateurs :

  - ##### En ligne de commande :
    Valeurs par défaut :
    - Répertoire personnel : **/home/<login>**
    - Langage de commande : **/bin/bash**
    - Infos : **''**
    - Uid : attribution automatique
    - Gid : attribution automatique

    Pour ajouter un ou plusieurs utilisateur(s) en ligne de commande, vous pouvez ajouter les logins directement avec les valeurs par défaut.

    Dans sa version par défaut, vous n'avez qu'à utiliser la commande `./user/pl add <liste_dutilisateurs>` et vous laisser guider par les instructions.

    Dans la version avec options, vous utiliserez la commande `./user.pl add <liste_d_utilisateurs> [-OPTIONS value]`.

 - ##### Depuis un fichier :

    Vous pouvez également créer des utilisateurs à partir d'un fichier. 
    Ce fichier respectera la norme suivante : 
    il sera composé d'un utilisateur à ajouter au système par ligne. Chaque ligne respectera le format suivant : *login*. 

    La commande associée à la création d'utilisateurs par un fichier est la suivante : `./user.pl -add -users <fichier> [-OPTIONS valeur]`.

- #### Suppression d'un utilisateur :

  Pour supprimer un utilisateur, utilisez la commande `./adminUser.pl remove <login>` suivi de l'option -n si vous souhaitez vérifier ce que la commande fera avant de l'éxecuter réelement. Cette commande supprimera l'utilisateur et son dossier personnel, merci de vérifier qu'aucun fichier important ne s'y trouve.

- #### Modification des données d'un utilisateur :

  Ce script vous permet, en plus de supprimer et ajouter des utilisateurs, de modifier leurs informations (mot de passe, répertoire personnel, langage de commade).

  Ces modifications sont appelées par une commande bien précise de la forme `./adminUser.pl modify login` suivi d'options selon l'information à modifier. Des exemples sont disponibles dans chaque sous-partie et vous pouvez bien sûr en utiliser plusieurs à la fois, du moment que vous respectez la syntaxe.

  Remarque : L'option `-n` sera toujours indiquée en fin de commande.

  - ##### Mot de passe :

    Pour modifier le mot de passe, on utilisera l'option `-p` suivie du nouveau mot de passe.

    Exemple : `./adminUser.pl modify ferrot -p nouveauPass`.

  - ##### Répertoire de travail :

    Pour modifier le répertoire de travail, on utilisera l'option `-d` suivie du nouveau répertoire personnel. L'ancien répertoire ne sera pas supprimé.

    Exemple : `./adminUser.pl modify ferrot -d /home/tferro`.

  - ##### Langage de commande :

    Pour modifier le langage de commande, on utilisera l'option `-l` suivie du nouveau langage de commande.

    Exemple : `./adminUser.pl modify ferrot -l /bin/bash`.

  Voici un exemple regroupant ces trois modifications : `./adminUser.pl modify ferrot -p nouveauPass -d /home/tferro -l /bin/bash`.

----------------------

### Documentation technique :

- #### Ajout d'un (de plusieurs) utilisateur(s) :

  Quelque soit la méthode de récupération des logins, la méthode d'ajout d'utilisateurs utilise une liste d'hashmaps. Pour chaque élément, cette méthode consiste à écrire la ligne correspondante dans les fichiers */etc/passwd* et */etc/shadow*. On créer ensuite le dossier personnel de l'utilisateur, on y copie les fichiers d'initialisation du shell puis on change les permissions et le propriétaire.

  - ##### En ligne de commande :

    Par la ligne de commande, les informations de l'utilisateur sont extraites puis envoyés dans un tableau d'hashmaps. Cette ligne est de la forme `./adminUser.pl add <login_1> <login_2> ... <login_n>`.

  - ##### Depuis un fichier :

    Depuis un fichier, on extrait les informations par un parcours de chaque ligne. On range ces données dans une hashmap puis on pousse cette dernière dans un tableau qui sera utilisé par la méthode d'ajout.

- #### Suppression d'un utilisateur :

  La commande `./adminUser.pl remove <login>` vérifie premièrement la présence de l'utilisateur grâce à la fonction Perl `getpwnam(<login>)` qui retourne les informations de l'utilisateur si il est présent dans le fichier */etc/passwd*. Si ce n'est pas le cas, le script s'arrête.

  Si l'utilisateur existe, on utilise la même technique pour supprimer la ligne correspondante à l'utilisateur dans les fichiers */etc/passwd*, */etc/shadow* et */etc/group*. Cette méthode consiste à ouvrir le fichier, recopier toutes les lignes dans une liste, de filtrer cette liste avec le nom de l'utilisateur avec la fonction `grep` puis de recopier la nouvelle liste en écrasant le fichier d'origine.

  Enfin, le script supprime récursivement le dossier personnel de l'utilisateur avec la méthode `remove_tree` de **File::Path**.

- #### Modification des données d'un utilisateur :

  Le principe de modification est toujours le même : cherche dans le fichier la ligne correspondante à l'utilisateur puis modifier cette ligne dans le champ à modifier. On ouvre donc le fichier, puis on utilise un `grep` pour trouver la ligne et un `split` pour décomposer cette ligne.

  - ##### Mot de passe :

    Le principe décrit plus haut est ici appliqué au fichier */etc/shadow*. On n'oublie pas de crypter le mot de passe en SHA-512 avec la commande `crypt(<password>, '$6$salt');`.

  - ##### Répertoire de travail :

    Pour changer le répertoire, on utilise là aussi la méthode, cette fois au fichier */etc/passwd*.

  - ##### Langage de commande :

    Enfin, pour changer le langage de commande, on demande le chemin vers ce dernier puis on utilise encore une fois le principe de modification encore une fois au fichier */etc/passwd*.
