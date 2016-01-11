#!/usr/bin/perl -w
# Explications claires : http://www.commentcamarche.net/contents/646-linux-gestion-des-utilisateurs

my $FICHIER_PASSWORD = 'passwd';
my $FICHIER_GROUP = 'group';
my $MAX_GID = 50000;
my $DEFAULT_GID = 50;

# containsOpt(@Tableau, $option)
sub containsOpt {
	$option = $_[$#_];
	for($i = 0; $i < $#_; $i++) {
		if ($_[$i] eq $option) {
			return 1;
		}
	}
	return undef;
}

sub add {
	%user=();
	print "Ajout de l'utilisateur « $_[0] » ...\n";
	$user{login}=$_;
	system("stty -echo");
	do {
		if($password1) {
			print "Erreur : Mots de passes différents\n";
		}
		print "Veuillez saisir votre mot de passe :\n";
		$password1 = <STDIN>;
		print "\n";
		print "Veuillez confirmer votre mot de passe :\n";
		$password2 = <STDIN>;
		print "\n";
	} while ($password1 ne $ password2);
	system("stty echo");
	$user{password} = $password1;
	$user{uid} = getGid();
	$user{gid} = $DEFAULT_GID;
	$user{commentaire} = $user{login};
	$user{repertoire} = '/home/' . $user{login};
	$user{programme_de_demarrage} = '/bin/bash';
}

sub getGid {
	open (READER, "< $FICHIER_PASSWORD") or die "open $FICHIER_PASSWORD : $!";
	chomp(my $derniereLigne = (reverse(<READER>))[0]);
	@line = split(':', $derniereLigne);
	$gid = $line[2];
	close(READER);
	if($gid and $gid <= $MAX_GID) {
		return $gid + 1;
	}
	return undef;
}


if (containsOpt(@ARGV, '-n')) {
	if (containsOpt(@ARGV, '-add')) {
		print "Utilisation : ./user.pl -add <login>\n";
		print "Permet l'ajout d'un utilisateur\n";
	}
	elsif (containsOpt(@ARGV, '-del')) {
		print "Utilisation : ./user.pl -del <login>\n";
		print "Permet de supprimer un utilisateur\n";
	}
	elsif (containsOpt(@ARGV, '-mdp')) {
		print "Utilisation : ./user.pl -mdp <login>\n";
		print "Permet de modifier son mot de passe\n";
	}
	elsif (containsOpt(@ARGV, '-home')) {
		print "Utilisation : ./user.pl -home <login>\n";
		print "Permet de modifier son repertoire de travail\n";
	}
	elsif (containsOpt(@ARGV, '-lang')) {
		print "Utilisation : ./user.pl -lang <login>\n";
		print "Permet de modifier le langage de commande\n";
	}
} else {
	if (containsOpt(@ARGV, '-add')) {
		shift;
		if ($ARGV[0]) {
			add($ARGV[0]);
		}
		else {
			print "Utilisation : ./user.pl -add <login>\n";
		}
	}
	elsif (containsOpt(@ARGV, '-del')) {
		del();
	}
	elsif (containsOpt(@ARGV, '-mdp')) {
		modifMdp();
	}
	elsif (containsOpt(@ARGV, '-home')) {
		modifHome();
	}
	elsif (containsOpt(@ARGV, '-lang')) {
		modifLang();
	}
	else {
		print "Option inconnue\n";
	}
}
=pod
Ajout de l'utilisateur « test » ...
Ajout du nouveau groupe « test » (1001) ...
Ajout du nouvel utilisateur « test » (1001) avec le groupe « test » ...
Création du répertoire personnel « /home/test »...
Copie des fichiers depuis « /etc/skel »...
Entrez le nouveau mot de passe UNIX : 
Retapez le nouveau mot de passe UNIX : 
passwd : le mot de passe a été mis à jour avec succès
Modification des informations relatives à l'utilisateur test
Entrez la nouvelle valeur ou « Entrée » pour conserver la valeur proposée
	Nom complet []: 
	N° de bureau []: 
	Téléphone professionnel []: 
	Téléphone personnel []: 
	Autre []: 
Ces informations sont-elles correctes ? [O/n] n
Modification des informations relatives à l'utilisateur test
Entrez la nouvelle valeur ou « Entrée » pour conserver la valeur proposée
	Nom complet []:   
	N° de bureau []: 
	Téléphone professionnel []: 
	Téléphone personnel []: 
	Autre []: 
Ces informations sont-elles correctes ? [O/n] o
=cut