#!/usr/bin/perl -w

use Getopt::Long;
use File::Copy qw/ copy /;
use File::Path qw(make_path remove_tree);

# Explications claires : http://www.commentcamarche.net/contents/646-linux-gestion-des-utilisateurs
# http://www.linux-perl-c.lami20j.fr/contenu/affiche-linux_tuto-4-creation-manuelle-d-un-utilisateur-:-le-mecanisme.html#top
my $MIN_UID = 1000;
my $MIN_GID = 1000;
my $FILE_HELP = 'useradd.help';
my $FILE_PASSWORD = 'passwd';
my $FILE_SHADOW = 'shadow';
my $FILE_GROUP = 'group';

# Options
my %opts = ();
GetOptions (
	'n=s@' => \$opts{n},
	'add' => \$opts{add},
	'modify' => \$opts{modify},
	'remove' => \$opts{remove},
	'home=s' => \$opts{home},
	'shell=s' => \$opts{shell},
	'infos=s' => \$opts{infos},
	'uid=i' => \$opts{uid},
	'gid=i' => \$opts{gid},
	'users=s' => \$opts{users}
) or die "Get options : $!";

# Informations de l'utilisateur avec valeurs par défaut
my %defaultUser = (
	uid => 1000,
	gid => 1000,
	infos => '',
	home => '/home/', # + login
	shell => '/bin/bash'
);

# Commande => Description de la commande
my %helpCommands = (
	"help" => "-help \nObtenir de l'aide",
	"add" => "-add [USER1 USER2 ... USERN]\nAjouter un ou plusieurs utilisateurs",
	"modify" => "-modify [USER1 USER2 ... USERN]\nModifier un ou plusieurs utilisateurs",
	"remove" => "-remove [USER1 USER2 ... USERN]\nSupprimer un ou plusieurs utilisateurs",
	"home" => "-home DIR\nUtilise REP (et le créé) comme repertoire personnel de l'utilisateur.",
	"shell" => "-shell SHELL\nUtilise SHELL comme programme de boot.",
	"uid" => "-uid ID\nForce le nouvel identifiant utilisateur à un entier donné. Echouera si l'uid existe déjà",
	"gid" => "-gid ID\nLorsqu'un utilisateur est créé, cette option place cet utilisateur dans ce groupe",
	"users" => "-users LOGINS\nCréé les utilisateurs à partir du fichier LOGIN"
);

# Retourne sous forme de tableau la liste des utilisateurs contenus dans un fichier
sub getUsers {
	my $file_users = shift;
	my @users;
	open(READER, "< $file_users") or die "open : $!";
	while (<READER>) {
		chomp($_);
		push(@users,$_);
	}
	close(READER);
	return @users;
}

# Ajoute un utilisateur
sub add { # (login)
	my %currUser = ();
	$currUser{login} = shift;
	if (! getpwnam($currUser{login})) {
		$currUser{password} = getCryptedPassword("test");
		(defined $opts{uid}) ? ($currUser{uid} = getUid($opts{uid})) : ($currUser{uid} = getUid($defaultUser{uid}));
		(defined $opts{gid}) ? ($currUser{gid} = getGid($opts{gid})) : ($currUser{gid} = getGid($defaultUser{gid}));
		(defined $opts{infos}) ? ($currUser{infos} = $opts{infos}) : ($currUser{infos} = $defaultUser{infos});
		(defined $opts{home}) ? ($currUser{home} = $opts{home}) : ($currUser{home} = $defaultUser{home} . $currUser{login});
		(defined $opts{shell}) ? ($currUser{shell} = $opts{shell}) : ($currUser{shell} = $defaultUser{shell});

		#print "$currUser{login}:x:$currUser{uid}:$currUser{gid}:$currUser{home}:$currUser{shell}\n";
		addEntryToFile($FILE_PASSWORD, "$currUser{login}:x:$currUser{uid}:$currUser{gid}:currUser{infos}:$currUser{home}:$currUser{shell}");
		addEntryToFile($FILE_SHADOW, "$currUser{login}:$currUser{password}:" . sprintf("%.0f", time/86400) . ":0:99999:7:::");
		addEntryToFile($FILE_GROUP, "$currUser{login}:x:$currUser{gid}");
		mkdir $currUser{home} or die "mkdir $currUser{home} : $!";
		#copy('/etc/skel/.bash*', $currUser{home}) or die "Copy : $!";
	}
	else {
		print "Nom d'utilisateur déjà utilisé\n";
	}
}

# Crypte le mot de passe passé en paramètre
sub getCryptedPassword { # (password)
	$password = shift;
	return crypt($password,'$6$sOmEsAlT');
}

# Retourne le premier Uid disponible après celui demandé
sub getUid # (uid)
{
	my $uid = shift;
	while(getpwuid($uid)) {
		$uid++;
	}
	return $uid;
}

# Retourne le premier Gid disponible après celui demandé
sub getGid # (gid)
{
	my $gid = shift;
	while(getgrgid($gid)) {
		$gid++;
	}
	return $gid;
}


# Ajoute une nouvelle ligne au fichier spécifié
sub addEntryToFile { # (file, line)
	my $file = shift;
	my $line = shift . "\n";

	open(WRITER, ">> $file") or die "open $file : $!";
	print WRITER $line;
	close(WRITER);
}

# Supprime un utilisateur
sub remove { # (login)
	my $user = shift;
	die "utilisateur inexistant" if (! getpwnam($user));
	# Trouve le dossier utilisateur :
	my $home = (getpwuid(getpwnam($user)))[7];

	# Suppression du dossier personnel :
	rmDirectory($home);
	# Suppression des lignes des fichiers :
	rmUserFromFile($FILE_PASSWORD, $user);
	rmUserFromFile($FILE_SHADOW, $user);
	rmUserFromFile($FILE_GROUP, $user);
}

# Supprime un dossier
sub rmDirectory { # (directory)
	$directory = shift;
	# On vérifie que le dossier existe
	if(-e $directory) {
		print "Suppression du repertoire $directory ...\n";
		remove_tree($directory) or die "remove_tree : $!";
	}
	else {
		die "$directory : dossier inexistant";
	}
}

# Supprime une ligne d'un fichier contenant login
sub rmUserFromFile { # (file, login)
	my $file = shift;
	my $login = shift;

	# On lit dans le fichier
	open(READER, "< $file") or die "open < $file : $!";
	my @contents = <READER>; # On récupère le contenu
	close(READER);
	# On supprime la ligne correspondante à l'utilisateur
	@contents = grep (!/^$login:/, @contents);
	# On écrase le fichier
	open(WRITER, "> $file") or die "open > $file : $!";
	print WRITER @contents;
	close(WRITER);
}

## "Main" ##
# Si option -n
if (defined($opts{n})) {
	# Pour toutes les commandes en argument
	foreach my $k (@{$opts{n}}) {
		# On supprime les "-" devant les arguments
		$k =~ s/^(-*)//;
		if (defined ($helpCommands{$k})) {
			print "$helpCommands{$k}\n";
		}
		else {
			print "Option inconnue\n";
		}
	}
}
else {
	# liste des logins
	my @users;
	# Si un fichier contenant les logins à été spécifié
	if (defined ($opts{users})) {
		push(@users, getUsers($opts{users}));
	}
	# On insére également dans users les utilisateurs en argument
	push(@users, @ARGV);
	foreach my $user (@users) {
		print "user : $user\n";
		if (defined ($opts{add})) {
 			add $user;
		}
		elsif (defined ($opts{modify})) {
			print "Modification de l'utilisateur $user\n";
		}
		elsif (defined ($opts{remove})) {
			print "Etes-vous sûr de supprimer l'utilisateur $user ?[O/N]\n";
			my $choice = <STDIN>;
			chomp $choice;
			if ($choice eq "O" or $choice eq "o") {
				remove $user;
				print "Suppression de $user effectuée avec succés\n";
			}
		}
		elsif (defined ($opts{help})) {

		}
		else {
			print "Erreur d'utilisation. Usage : ./user <commande> [OPTIONS] login1 login2 ...\n";
		}
	}
}