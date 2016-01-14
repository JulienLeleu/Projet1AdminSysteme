#!/usr/bin/perl -w

use Getopt::Long;

# Explications claires : http://www.commentcamarche.net/contents/646-linux-gestion-des-utilisateurs
my $MIN_UID = 1000;
my $MIN_GID = 1000;
my $FILE_HELP = 'useradd.help';
my $FILE_PASSWORD = 'passwd';
my $FILE_SHADOW = 'shadow';
my $FILE_GROUP = 'group';

# Informations de l'utilisateur avec valeurs par défaut
my %user = (
	login => undef,
	password => undef,
	uid => getUid($MIN_UID),
	gid => getGid($MIN_GID),
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
	"--gid" => "--gid ID\nLorsqu'un utilisateur est créé, cette option place cet utilisateur dans ce groupe",
	"--users" => "--users LOGINS\nCréé les utilisateurs à partir du fichier LOGIN"
);

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
		my $value = $args{$key};
		# si l'option existe, on range la valeur dans l'utilisateur
		if (defined $helpCommands{$key}) {
			# on supprime le "--" devant l'option
			$key =~ s/^--//;
			$user{$key}=$value;
		}
	}
	print "Indiquez votre nom d'utilisateur :\n";
	$user{login} = <STDIN>;
	chomp $user{login};
	print "Ajout de l'utilisateur « $user{login} » ...\n";
	#$user{password} = getPassword();
	if (exists $args{"--uid"}) {
		$user{uid} = getUid($user{uid});
	}
	print "Ajout de l'uid ($user{uid})\n";
	if (exists $args{"--gid"}) {
		$user{gid} = getGid($user{gid});
	}
	print "Ajout du nouvel utilisateur « $user{login} » ($user{uid}) avec le groupe ($user{gid})\n";
	print "Informations relatives à l'utilisateur $user{login} :\n";
	$user{infos} = <STDIN>;
	chomp $user{infos};
	if (!exists $args{"--home"}) {
		$user{home} = "/home/" . $user{login};
	}
	print "Création du répertoire personnel « $user{home} »...\n";
	print "Création du repertoire bash « $user{shell} »...\n";
}

#sub getPassword {
#	system("stty -echo");
#	my $password1 = undef;
#	my $password2 = undef;
#	do {
#		if(defined $password1) {
#			print "Erreur : Mots de passes différents\n";
#		}
#		print "Entrez le nouveau mot de passe UNIX :\n";
#		$password1 = <STDIN>;
#		print "\n";
#		print "Retapez le nouveau mot de passe UNIX :\n";
#		$password2 = <STDIN>;
#		print "\n";
#	} while ($password1 ne $ password2);
#	system("stty echo");
#	return chomp $password1;
#}

sub getUid {
	my $UID = shift;
	while(getpwuid($UID)) {
		$UID++;
	}
	return $UID;
}

sub getGid {
	my $GID = shift;
	while(getgrgid($GID)) {
		$GID++;
	}
	return $GID;
}
sub writePasswd {
	open(WRITER, ">> $FILE_PASSWORD");
	print WRITER "$user{login}:x:$user{uid}:$user{gid}:$user{infos}:$user{home}:$user{shell}\n";
	close(WRITER);
}

sub writeShadow {
	my $date = sprintf("%.0f", time/86400);
	open(WRITER, ">> $FILE_SHADOW");
	print WRITER "$user{login}:x:$date:0:99999:7:::\n";
	close(WRITER);
}

sub writeGroup {
	#login:x:gid:
	open(WRITER, ">> $FILE_GROUP");
	print WRITER "$user{login}:x:$user{gid}:\n";
	close(WRITER);
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
		# On récupère le nombre d'utilisateurs (> 0)
		my $nbUsers = pop @ARGV;
		if ($nbUsers < 1) {
			die "Nombre d'utilisateurs incorrect : $nbUsers";
		}
		# Récupération des options
		GetOptions (
			'home=s' => \$args{home},
			'shell=s' => \$args{shell},
			'uid=i' => \$args{uid},
			'gid=i' => \$args{gid},
			'users=s' => \$args{users}
		);
		
		# Récupère les infos
		my $i=0;
		while ($i++ < $nbUsers) {
			print "User($i) : ";
			getUser();
			writePasswd();
			writeShadow();
			writeGroup();
			system("passwd -r $FILE_SHADOW $user{login}");
			$nbUsers--;
		}
		## A supprimer
		#foreach my $k (keys(%args)) {
		#	print "$k ==> $args{$k}\n";
		#}
	}
}