#!/usr/bin/perl -w
# Explications claires : http://www.commentcamarche.net/contents/646-linux-gestion-des-utilisateurs

# Informations de l'utilisateur avec valeurs par défaut
my %user = (
	login => undef,
	password => undef,
	uid => undef,
	gid => 50,
	infos => undef,
	home => '/home/',
	shell => '/bin/bash'
);

# Options
my %args = ();

my %helpCommands = (
	"--home" => "--home DIR\nUtilise REP (et le créé) comme repertoire personnel de l'utilisateur.",
	"--shell" => "--shell SHELL\nUtilise SHELL comme programme de boot.",
	"--uid" => "--uid ID\nForce le nouvel identifiant utilisateur à un entier donné. Echouera si l'uid existe déjà",
	"--gid" => "--gid ID\nLorsqu'un utilisateur est créé, cette option place cet utilisateur dans ce groupe"
);

my $FILE_HELP = 'useradd.help';
my $FILE_PASSWORD = 'passwd';
my $FILE_GROUP = 'group';

# Récupère les options et les rangent dans %args
sub getArgs {
	%args = @_;
	#verification des arguments
	foreach	my $k (keys(%args)) {
		if ($k !~ m/^--(.+)/) {
			die "option inconnue : $k\n";
		}
	}
}

# Retourne 1 si l'option est contenue dans le tableau passé en param
sub containsOpt {	# @tab, $option
	$option = $_[$#_];
	for($i = 0; $i < $#_; $i++) {
		if ($_[$i] eq $option) {
			return 1;
		}
	}
	return undef;
}

sub displayFile {
	open (READER, "< $FILE_HELP");
	while(<READER>) {
		print;
	}
	close(READER);
}

sub getUser {
	# vérifier les options, les insérer dans user
	foreach my $key (keys(%args)) {
		$value = $args{$key};
		# si l'option existe, on range la valeur dans l'utilisateur
		if (defined $helpCommands{$key}) {
			# on supprime le "--" devant l'option
			$key =~ s/^--//;
			$user{$key}=$value;
		}
	}
	$user{login}=$_[0];
	print "Ajout de l'utilisateur « $user{login} » ...\n";
	if (!exists $args{"--home"}) {
		$user{home} = $user{home} . $user{login};
	}
	print "Création du répertoire personnel « $user{home} »...\n";

	$user{password} = getPassword();

}

sub getPassword {
	system("stty -echo");
	do {
		if(defined $password1) {
			print "Erreur : Mots de passes différents\n";
		}
		print "Entrez le nouveau mot de passe UNIX :\n";
		$password1 = <STDIN>;
		print "\n";
		print "Retapez le nouveau mot de passe UNIX :\n";
		$password2 = <STDIN>;
		print "\n";
	} while ($password1 ne $ password2);
	system("stty echo");
	return $password1;
}

# Si l'utilisateur fait ./useradd.pl --help
if (containsOpt(@ARGV,'-h') or containsOpt(@ARGV,'--help')) {
	system("clear");
	displayFile($FILE_HELP);
}
else {
	# Si l'utilisateur fait ./useradd.pl -n [options]
	if (defined $ARGV[0] and $ARGV[0] eq '-n') {
		shift;
		foreach my $k (@ARGV) {
			if (defined $helpCommands{$k}) {
				print "$helpCommands{$k}\n";
			}
			else {
				print "Option inconnue\n";
			}
		}
	}
	else {
		# récupérer les options => stocker dans un tableau
		# récupérer les utilisateurs => stocker dans tableau

		# On récupère les logins (dernier argument)
		$login = pop @ARGV;
		# Récupération des options
		getArgs(@ARGV);
		# Récupère les infos
		getUser($login);

		## A supprimer
		foreach my $k (keys(%args)) {
			print "$k ==> $args{$k}\n";
		}
	}
}