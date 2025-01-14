#!/bitnami/megastack-linux-x64/output/perl/bin/perl
#
# Fetches the latest ModSecurity Ruleset
#

use strict;
use Sys::Hostname;
use LWP::UserAgent ();
use LWP::Debug qw(-);
use URI ();
use HTTP::Date ();
use Cwd qw(getcwd);
use Getopt::Std;

my $VERSION = "0.0.1";
my($SCRIPT) = ($0 =~ m/([^\/\\]+)$/);
my $CRLFRE = qr/\015?\012/;
my $HOST = Sys::Hostname::hostname();
my $UNZIP = [qw(unzip -a)];
my $SENDMAIL = [qw(/usr/lib/sendmail -oi -t)];
my $HAVE_GNUPG = 0;
my %PREFIX_MAP = (
	-dev => 0,
	-rc => 1,
	"" => 9,
);
my %GPG_TRUST = ();
my $REQUIRED_SIG_TRUST;

eval "use GnuPG qw(:trust)";
if ($@) {
	warn "Could not load GnuPG module - cannot verify ruleset signatures\n";
}
else {
	$HAVE_GNUPG = 1;
	%GPG_TRUST = (
		&TRUST_UNDEFINED    => "not",
		&TRUST_NEVER        => "not",
		&TRUST_MARGINAL     => "marginally",
		&TRUST_FULLY        => "fully",
		&TRUST_ULTIMATE     => "ultimatly",
	);
	$REQUIRED_SIG_TRUST = &TRUST_FULLY;
}

################################################################################
################################################################################

my @fetched = ();
my %opt = ();
getopts('c:r:p:s:v:t:e:f:EuS:D:R:U:F:L:ldh', \%opt);

usage(1) if(defined $opt{h});
usage(1) if(@ARGV > 1);

# Make sure we have an action
if (! grep { defined } @opt{qw(S D R U F L l)}) {
	usage(1, "Action required.");
}

# Merge config with commandline opts
if ($opt{c}) {
	%opt = parse_config($opt{c}, \%opt);
}

LWP::Debug::level("+") if ($opt{d});

# Make the version into a regex
if (defined $opt{v}) {
	my($a,$b,$c,$d) = ($opt{v} =~ m/^(\d+)\.?(\d+)?\.?(\d+)?(?:-(\D+\d+$)|($))/);
	if (defined $d) {
		(my $key = $d) =~ s/^(\D+)\d+$/-$1/;
		unless (exists $PREFIX_MAP{$key}) {
			usage(1, "Invalid version (bad suffix \"$d\"): $opt{v}");
		}
		$opt{v} = qr/^$a\.$b\.$c-$d$/;
	}
	elsif (defined $c) {
		$opt{v} = qr/^$a\.$b\.$c(?:-|$)/;
	}
	elsif (defined $b) {
		$opt{v} = qr/^$a\.$b\./;
	}
	elsif (defined $a) {
		$opt{v} = qr/^$a\./;
	}
	else {
		usage(1, "Invalid version: $opt{v}");
	}
	if ($opt{d}) {
		print STDERR "Using version regex: $opt{v}\n";
	}
}
else {
	$opt{v} = qr/^/;
}

# Remove trailing slashes from uri and path
$opt{r} =~ s/\/+$//;
$opt{p} =~ s/\/+$//;

# Required opts
usage(1, "Repository (-r) required.") unless(defined $opt{r});
usage(1, "Local path (-p) required.") unless(defined $opt{p} or defined $opt{l});

my $ua = LWP::UserAgent->new(
	agent => "ModSecurity Updator/$VERSION",
	keep_alive => 1,
	env_proxy => 1,
	max_redirect => 5,
	requests_redirectable => [qw(GET HEAD)],
	timeout => ($opt{t} || 600),
);

sub usage {
	my $rc = defined($$_[0]) ? $_[0] : 0;
	my $msg = defined($_[1]) ? "\n$_[1]\n\n" : "";

	print STDERR << "EOT";
${msg}Usage: $SCRIPT [-c config_file] [[options] [action]

 Options (commandline will override config file):
  -r uri   RepositoryURI   Repository URI.
  -p path  LocalRepository Local repository path to use as base for downloads.
  -s path  LocalRules      Local rules base path to use for unpacking.
  -v text  Version         Full/partial version (EX: 1, 1.5, 1.5.2, 1.5.2-dev3)
  -t secs  Timeout         Timeout for fetching data in seconds (default 600).
  -e addr  NotifyEmail     Notify via email on update (comma separated list).
  -f addr  NotifyEmailFrom From address for notification email.
  -u       Unpack          Unpack into LocalRules/version path.
  -d       Debug           Print out lots of debugging.

 Actions:
  -S name    Fetch the latest stable ruleset, "name"
  -D name    Fetch the latest development ruleset, "name"
  -R name    Fetch the latest release candidate ruleset, "name"
  -U name    Fetch the latest unstable (non-stable) ruleset, "name"
  -F name    Fetch the latest ruleset, "name"
  -l         Print listing of what is available

 Misc:
  -c         Specify a config file for options.
  -h         This help

Examples:

# Get a list of what the repository contains:
$SCRIPT -rhttp://host/repo/ -l

# Get a partial list of versions 1.5.x:
$SCRIPT -rhttp://host/repo/ -v1.5 -l

# Get the latest stable version of "breach_ModSecurityCoreRules":
$SCRIPT -rhttp://host/repo/ -p/my/repo -Sbreach_ModSecurityCoreRules

# Get the latest stable 1.5 release of "breach_ModSecurityCoreRules":
$SCRIPT -rhttp://host/repo/ -p/my/repo -v1.5 -Sbreach_ModSecurityCoreRules
EOT
	exit $rc;
}

sub sort_versions {
	(my $A = $a) =~ s/^(\d+)\.(\d+)\.(\d+)(-[^-\d]+|)(\d*)$/sprintf("%03d%03d%03d%03d%03d", $1, $2, $3, $PREFIX_MAP{$4}, $5)/e;
	(my $B = $b) =~ s/^(\d+)\.(\d+)\.(\d+)(-[^-\d]+|)(\d*)$/sprintf("%03d%03d%03d%03d%03d", $1, $2, $3, $PREFIX_MAP{$4}, $5)/e;
	return $A cmp $B;
}

sub parse_config {
	my($file,$clo) = @_;
	my %cfg = ();

	print STDERR "Parsing config: $file\n" if ($opt{d});
	open(CFG, "<$file") or die "Failed to open config \"$file\": $!\n";
	while(<CFG>) {
		# Skip comments and empty lines
		next if (/^\s*(?:#|$)/);

		# Parse
		chomp;
		my($var,$q1,$val,$q2) = (m/^\s*(\S+)\s+(['"]?)(.*)(\2)\s*$/);

		# Fixup values
		$var = lc($var);
		if ($val =~ m/^(?:true|on)$/i) { $val = 1 };
		if ($val =~ m/^(?:false|off)$/i) { $val = 0 };

		# Set opts
		if    ($var eq "repositoryuri")       { $cfg{r} = $val }
		elsif ($var eq "localrepository")        { $cfg{p} = $val }
		elsif ($var eq "localrules")       { $cfg{s} = $val }
		elsif ($var eq "version")          { $cfg{v} = $val }
		elsif ($var eq "timeout")          { $cfg{t} = $val }
		elsif ($var eq "notifyemail")      { $cfg{e} = $val }
		elsif ($var eq "notifyemailfrom")  { $cfg{f} = $val }
		elsif ($var eq "notifyemaildiff")  { $cfg{E} = $val }
		elsif ($var eq "unpack")           { $cfg{u} = $val }
		elsif ($var eq "debug")            { $cfg{d} = $val }
		else { die "Invalid config directive: $var\n" }
	}
	close CFG;

	my($k, $v);
	while (($k, $v) = each %{$clo || {}}) {
		$cfg{$k} = $v if (defined $v);
	}

	return %cfg;
}

sub repository_dump {
	my @replist = repository_listing();

	print STDERR "\nRepository: $opt{r}\n\n";
	unless (@replist) {
		print STDERR "No matching entries.\n";
		return;
	}

	for my $repo (@replist) {
		print "$repo {\n";
		my @versions = ruleset_available_versions($repo);
		for my $version (@versions) {
			if ($version =~ m/$opt{v}/) {
				printf "%15s: %s_%s.zip\n", $version, $repo, $version;
			}
			elsif ($opt{d}) {
				print STDERR "Skipping version: $version\n";
			}
		}
		print "}\n";
	}
}

sub repository_listing {
	my $res = $ua->get("$opt{r}/.listing");
	unless ($res->is_success()) {
		die "Failed to get repository listing \"$opt{r}/.listing\": ".$res->status_line()."\n";
	}
	return grep(/\S/, split(/$CRLFRE/, $res->content)) ;
}

sub ruleset_listing {
	my $res = $ua->get("$opt{r}/$_[0]/.listing");
	unless ($res->is_success()) {
		die "Failed to get ruleset listing \"$opt{r}/$_[0]/.listing\": ".$res->status_line()."\n";
	}
	return grep(/\S/, split(/$CRLFRE/, $res->content)) ;
}

sub ruleset_available_versions {
	return sort sort_versions map { m/_([^_]+)\.zip.*$/; $1 } ruleset_listing($_[0]);
}

sub ruleset_fetch {
	my($repo, $version) = @_;

	# Create paths
	if (! -e "$opt{p}" ) {
		mkdir "$opt{p}" or die "Failed to create \"$opt{p}\": $!\n";
	}
	if (! -e "$opt{p}/$repo" ) {
		mkdir "$opt{p}/$repo" or die "Failed to create \"$opt{p}/$repo\": $!\n";
	}

	my $fn = "${repo}_$version.zip";
	my $ruleset = "$repo/$fn";
	my $ruleset_sig = "$repo/$fn.sig";

	if (-e "$opt{p}/$ruleset") {
		die "Refused to overwrite ruleset \"$opt{p}/$ruleset\".\n";
	}

	# Fetch the ruleset
	print STDERR "Fetching: $ruleset ...\n";
	my $res = $ua->get(
		"$opt{r}/$ruleset",
		":content_file" => "$opt{p}/$ruleset",
	);
	die "Failed to retrieve ruleset $ruleset: ".$res->status_line()."\n" unless ($res->is_success());

	# Fetch the ruleset signature
	if (-e "$opt{p}/$ruleset_sig") {
		die "Refused to overwrite ruleset signature \"$opt{p}/$ruleset_sig\".\n";
	}
	$res = $ua->get(
		"$opt{r}/$ruleset_sig",
		":content_file" => "$opt{p}/$ruleset_sig",
	);

	# Verify the signature if we can
	if ($HAVE_GNUPG) {
		die "Failed to retrieve ruleset signature $ruleset_sig: ".$res->status_line()."\n" unless ($res->is_success());

		ruleset_verifysig("$opt{p}/$ruleset", "$opt{p}/$ruleset_sig");
	}
	push @fetched, [$repo, $version, $ruleset, undef];
}

sub ruleset_unpack {
	my($repo, $version, $ruleset) = @{ $_[0] || [] };
	my $fn = "$opt{p}/$ruleset";

	if (! -e "$fn" ) {
		die "Internal Error: No ruleset to unpack - \"$fn\"\n";
	}

	# Create paths
	if (! -e "$opt{s}" ) {
		mkdir "$opt{s}" or die "Failed to create \"$opt{p}\": $!\n";
	}
	if (! -e "$opt{s}/$repo" ) {
		mkdir "$opt{s}/$repo" or die "Failed to create \"$opt{p}/$repo\": $!\n";
	}
	if (! -e "$opt{s}/$repo/$version" ) {
		mkdir "$opt{s}/$repo/$version" or die "Failed to create \"$opt{p}/$repo/$version\": $!\n";
	}
	else {
		die "Refused to overwrite previously unpacked \"$opt{s}/$repo/$version\".\n";
	}

	# TODO: Verify sig

	my $pwd = getcwd();
	my $unpackdir = "$opt{s}/$repo/$version";
	chdir "$unpackdir";
	if ($@) {
		my $err = $!;
		chdir $pwd;
		die "Failed to chdir to \"$unpackdir\": $err\n";
	}
	undef $!;
	system(@$UNZIP, $fn);
	if ($? != 0) {
		my $err = $!;
		chdir $pwd;
		die "Failed to unpack \"$unpackdir\"".($err?": $err":".")."\n";
	}
	chdir $pwd;

	# Add where we unpacked it
	$_->[3] = $unpackdir;

	return 0;
}

sub ruleset_fetch_latest {
	my($repo, @type) = @_;
	my @versions = ruleset_available_versions($repo);
	my $verre = defined($opt{v}) ? qr/^$opt{v}/ : qr/^/;
	my $typere = undef;
	
	# Figure out what to look for
	if (@type == 1 and $type[0] ne "") {
        my $type = $type[0];
		if ($type eq "UNSTABLE") {
			$typere = qr/\d-\D+\d+$/;
		}
		else {
			$typere = qr/\d-$type\d+$/;
		}
	}
	elsif (@type > 1) {
        my $type;
        for (@type) {
            if ($_ eq "") {
                $type .= ($type?"|":"").qr/\.\d+$/;
            }
            elsif ($_ eq "UNSTABLE") {
                $type .= ($type?"|":"").qr/\d-\D+\d+$/;
            }
            else {
                $type .= ($type?"|":"").qr/\d-$_\d+$/;
            }
        }

        $typere = qr/$type/;
    }
    else {
		$typere = qr/\.\d+$/;
    }

    if ($opt{d}) {
        print STDERR "REPO: $repo\n";
        print STDERR "TYPES: ".join(", ", @type)."\n";
        print STDERR "VERSIONS: ".join(", ", @versions)."\n";
        print STDERR "REGEX: version=$opt{v} type=$typere\n";
    }

	while (@versions) {
		my $last = pop(@versions);
		# Check REs on version
		if ($last =~ m/$opt{v}/ and (!defined($typere) || $last =~ m/$typere/)) {
			return ruleset_fetch($repo, $last);
		}
		if ($opt{d}) {
			print STDERR "Skipping version: $last\n";
		}
	}

	die "No '".join("' or '", @type)."' ruleset found.\n";
}

sub notify_email {
	my $version_text = join("\n", map { "$_->[0] v$_->[1]".(defined($_->[3])?": $_->[3]":"") } @_);
	my $from = $opt{f} ? "From: $opt{f}\n" : "";
	my $body = << "EOT";
ModSecurity rulesets updated and ready to install on host $HOST:

$version_text

ModSecurity - http://www.modsecurity.org/
EOT

	# TODO: Diffs

	open(SM, "|-", @$SENDMAIL) or die "Failed to send mail: $!\n";
	print STDERR "Sending notification email to: $opt{e}\n";
	print SM << "EOT";
${from}To: $opt{e}
Subject: [$HOST] ModSecurity Ruleset Update Notification

$body
EOT
	close SM;
}

sub ruleset_verifysig {
	my($fn, $sigfn) = @_;

	print STDERR "Verifying \"$fn\" with signature \"$sigfn\"\n";
	my $gpg = new GnuPG();
	my $sig = eval { $gpg->verify( signature => $sigfn, file => $fn ) };
	if (defined $sig) {
		print STDERR sig2str($sig)."\n"; 
	}
	if (!defined($sig)) {
		die "Signature validation failed.\n";
	}
	if ( $sig->{trust} < $REQUIRED_SIG_TRUST ) {
		die "Signature is not trusted ".$GPG_TRUST{$REQUIRED_SIG_TRUST}.".\n";
	}

	return;
}

sub sig2str {
	my %sig = %{ $_[0] || {} };
	"Signature made ".localtime($sig{timestamp})." by $sig{user} (ID: $sig{keyid}) and is $GPG_TRUST{$sig{trust}} trusted.";
}

################################################################################
################################################################################

# List what is there
if ($opt{l}) { repository_dump(); exit 0 }
# Latest stable
elsif (defined($opt{S})) { ruleset_fetch_latest($opt{S}, "") }
# Latest development
elsif (defined($opt{D})) { ruleset_fetch_latest($opt{D}, "dev") }
# Latest release candidate
elsif (defined($opt{R})) { ruleset_fetch_latest($opt{R}, "rc") }
# Latest unstable
elsif (defined($opt{U})) { ruleset_fetch_latest($opt{U}, "UNSTABLE") }
# Latest release candidate or stable
elsif (defined($opt{L})) { ruleset_fetch_latest($opt{R}, "rc", "") }
# Latest (any type)
elsif (defined($opt{F})) { ruleset_fetch_latest($opt{F}, undef) }

# Unpack
if ($opt{u}) {
	if (! defined $opt{s} ) { usage(1, "LocalRules is required for unpacking.") }
	for (@fetched) {
		ruleset_unpack($_);
	}
}

# Unpack
if ($opt{e}) {
	notify_email(@fetched);
}
