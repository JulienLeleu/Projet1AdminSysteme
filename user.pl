#!/usr/bin/perl -w

use Getopt::Long;

# Explications claires : http://www.commentcamarche.net/contents/646-linux-gestion-des-utilisateurs
# http://www.linux-perl-c.lami20j.fr/contenu/affiche-linux_tuto-4-creation-manuelle-d-un-utilisateur-:-le-mecanisme.html#top
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
	uid => $MIN_UID,
	gid => $MIN_GID,
	infos => undef,
	home => '/home/',
	shell => '/bin/bash'
);

my %helpCommands = (
	"help" => "--help \nObtenir de l'aide",
	"add" => "--add [USER1 USER2 ... USERN]\nAjouter un ou plusieurs utilisateurs",
	"modify" => "--modify [USER1 USER2 ... USERN]\nModifier un ou plusieurs utilisateurs",
	"remove" => "--remove [USER1 USER2 ... USERN]\nSupprimer un ou plusieurs utilisateurs",
	"home" => "--home DIR\nUtilise REP (et le créé) comme repertoire personnel de l'utilisateur.",
	"shell" => "--shell SHELL\nUtilise SHELL comme programme de boot.",
	"uid" => "--uid ID\nForce le nouvel identifiant utilisateur à un entier donné. Echouera si l'uid existe déjà",
	"gid" => "--gid ID\nLorsqu'un utilisateur est créé, cette option place cet utilisateur dans ce groupe",
	"users" => "--users LOGINS\nCréé les utilisateurs à partir du fichier LOGIN"
);

# Options
my %opts = ();

GetOptions (
	'n=s@' => \$opts{n},
	'add' => \$opts{add},
	'modify' => \$opts{modify},
	'remove' => \$opts{remove},
	'home=s' => \$opts{home},
	'shell=s' => \$opts{shell},
	'uid=i' => \$opts{uid},
	'gid=i' => \$opts{gid},
	'users=s' => \$opts{users}
);




if (defined($opts{n})) {
	foreach my $k (@{$opts{n}}) {
		$k =~ s/^(-*)//;
		if (defined ($helpCommands{$k})) {
			print "$helpCommands{$k}\n";
		}
		print "Option inconnue\n";
	}
}
else {
	@users = @ARGV;
	foreach my $k (@users) {
		if (defined ($opts{add})) {
 			
		}
		else if (defined ($opts{modify})) {

		}
		else if (defined ($opts{remove})) {

		}
		else if (defined ($opts{help})) {

		}
	}
}