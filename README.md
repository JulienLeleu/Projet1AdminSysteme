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

### Liste des fonctionnalités implémentées :

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
    - UID : attribution automatique
    - GID : attribution automatique

    Pour ajouter un ou plusieurs utilisateur(s) en ligne de commande, vous pouvez ajouter les logins directement avec les valeurs par défaut.

    Dans sa version par défaut, vous n'avez qu'à utiliser la commande `./user/pl add <liste_dutilisateurs>` et vous laisser guider par les instructions.

    Dans la version avec options, vous utiliserez la commande `./user.pl add <liste_d_utilisateurs> [-OPTIONS value]`.

 - ##### Depuis un fichier :

    Vous pouvez également créer des utilisateurs à partir d'un fichier. 
    Ce fichier respectera la norme suivante : 
    il sera composé d'un utilisateur à ajouter au système par ligne. Chaque ligne respectera le format suivant : *login*. 

    La commande associée à la création d'utilisateurs par un fichier est la suivante : `./user.pl -add -users <fichier> [-OPTIONS valeur]`.

- #### Suppression d'un utilisateur :

  Pour supprimer un utilisateur, utilisez la commande `./user.pl -remove <liste_des_login>`. Cette commande supprimera l'utilisateur et son dossier personnel après confirmation.

- #### Modification des données d'un utilisateur :

  Ce script vous permet, en plus de supprimer et ajouter des utilisateurs, de modifier leurs informations (mot de passe, répertoire personnel, langage de commande).

  Ces modifications sont appelées par une commande bien précise de la forme `./user.pl -modify <liste_des_login>` suivi d'options selon l'information à modifier. Les options seront alors pris en compte pour chaques utilisateurs de la liste. Pour modifier les informations, le programme vous demandera au préalable le mot de passe de chaque login.

  - ##### Mot de passe :

    Pour modifier le mot de passe, on appelera la commande comme telle : `./user.pl -modify <login>`.
    Le script vous demande alors si vous souhaitez modifier votre mot de passe. Suivez ensuite les instructions.

  - ##### Répertoire de travail :

    Pour modifier le répertoire de travail, on utilisera l'option `-home` suivie du nouveau répertoire personnel. L'ancien répertoire sera déplacé à l'emplacement spécifié et renommé avec ce même nouveau nom.

    Exemple : `./user.pl -modify <login> -home <nouveauDossier>`.

  - ##### Langage de commande :

    Pour modifier le langage de commande, on utilisera l'option `-shell` suivie du nouveau langage de commande.

    Exemple : `./user.pl -modify <login> -home <nouveauLangageDeCommande>`.

----------------------

### Documentation technique :

- #### Ajout d'un (de plusieurs) utilisateur(s) :

  Quelque soit la méthode de récupération des logins, pour chaque utilisateurs, le script écrit la ligne correspondante dans les fichiers */etc/passwd* et */etc/shadow*. On crée ensuite le dossier personnel de l'utilisateur et on y copie les fichiers d'initialisation du shell.

  - ##### En ligne de commande :

    Par la ligne de commande, les logins sont stockés dans un tableau. Ils sont ensuite parcourus un à un. Ensuite, les informations de l'utilisateur sont extraites une a une et envoyées une à une dans les fichiers de configuration /etc/passwd /etc/shadow /etc/group. Cette ligne est de la forme `./user.pl -add <login_1> <login_2> ... <login_n> [-OPTIONS valeur]`.

  - ##### Depuis un fichier :

    Depuis un fichier, on extrait les informations par un parcours de chaque ligne. On range la liste des logins dans un tableau, le même que pour celui en ligne de commande. On peut donc ajouter des utilisateurs par fichier ET par ligne de commande.

- #### Suppression d'un utilisateur :

  La commande `./user.pl -remove <login>` vérifie premièrement la présence de l'utilisateur grâce à la fonction Perl `getpwnam(<login>)` qui retourne les informations de l'utilisateur si il est présent dans le fichier */etc/passwd*. Si ce n'est pas le cas, le script s'arrête.

  Si l'utilisateur existe, on utilise la même technique pour supprimer la ligne correspondante à l'utilisateur dans les fichiers */etc/passwd*, */etc/shadow* et */etc/group*. Cette méthode consiste à ouvrir le fichier, recopier toutes les lignes dans une liste, de filtrer cette liste avec le nom de l'utilisateur avec la fonction `grep` puis de recopier la nouvelle liste en écrasant le fichier d'origine.

  Enfin, le script supprime récursivement le dossier personnel de l'utilisateur avec la méthode `remove_tree` de **File::Path**.

- #### Modification des données d'un utilisateur :

  Le principe de modification est le suivant: On appelle supprime la ligne correspondante en gardant au préalable les informations qui seront inchangées, on ajoute ensuite avec la fonction d'ajout d'utilisateur la ligne correspondante avec les nouvelles valeurs. Cette manière de fonctionner pourrait être optimisée davantage, mais permet d'avoir un code plus "structuré" et davantage compréhensible.

  - ##### Mot de passe :

    Le principe décrit plus haut est ici appliqué au fichier */etc/shadow*. Il faut crypter le mot de passe en SHA-512 avec la commande `crypt(<password>, '$6$salt');`.

  - ##### Répertoire de travail :

    Pour changer le répertoire, on modifie la valeur du repertoire dans le fichier */etc/passwd*. On utilise ensuite la commande mv qui permet de déplacer un repertoire en perl.

  - ##### Langage de commande :

    Pour modifier le langage de commande, on récupère la valeur de l'option correspondante avec le chemin vers ce dernier puis on utilise encore une fois le principe de modification sur le fichier */etc/passwd*.
