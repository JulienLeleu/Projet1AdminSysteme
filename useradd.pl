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
	bootProgram => '/bin/bash'
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

sub getArgs {
	%args = @_;
	#verification des arguments
	foreach	my $k (keys(%args)) {
		if ($k !~ m/^--(.+)/) {
			die "option inconnue : $k\n";
		}
	}
}

sub containsOpt {
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

sub add {
	# vérifier les options, les insérer dans user
}

if (containsOpt(@ARGV,'-h')) {
	system("clear");
	displayFile($FILE_HELP);
}
else {
	if ($ARGV[0] eq '-n') {
		shift;
		foreach my $k (@ARGV) {
			print "$helpCommands{$k}\n";
		}
	}
	else {
		getArgs(@ARGV);
		add();
		foreach my $k (keys(%args)) {
			print "$k ==> $args{$k}\n";
		}
	}
}