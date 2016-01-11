#!/usr/bin/perl -w

$FICHIERPASSWORD = 'passwd';


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
	print "Veuillez saisir votre nom de compte :\n";
	$user{login}=<STDIN>;
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
	$user{password}=$password1;
	$user{uid}= getGid();
}

sub getGid {
	my @listeGid;
	open (READER, "< $FICHIERPASSWORD") or die "open $FICHIERPASSWORD : $!";
	while(<READER>) {
		@line = split(':', $_);
		$gid = $line[2];
		print $gid . "\n";
		
	}
	close(READER);
}


if (containsOpt(@ARGV, '-n')) {
	if (containsOpt(@ARGV, '-add')) {
		print "Permet l'ajout d'un utilisateur\n";
	}
	elsif (containsOpt(@ARGV, '-remove')) {
		print "Permet de supprimer un utilisateur\n";
	}
	elsif (containsOpt(@ARGV, '-mdp')) {
		print "Permet de modifier son mot de passe\n";
	}
	elsif (containsOpt(@ARGV, '-home')) {
		print "Permet de modifier son repertoire de travail\n";
	}
	elsif (containsOpt(@ARGV, '-lang')) {
		print "Permet de modifier le langage de commande\n";
	}
} else {
	if (containsOpt(@ARGV, '-add')) {
		add();
	}
	elsif (containsOpt(@ARGV, '-del')) {
		remove();
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
}