#!/bitnami/megastack-linux-x64/output/perl/bin/perl
#
# ModSecurity for Apache 2.x, http://www.modsecurity.org/
# Copyright (c) 2004-2011 Trustwave Holdings, Inc. (http://www.trustwave.com/)
#
# You may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# If any of the files related to licensing are missing or if you have any
# other questions related to licensing please contact Trustwave Holdings, Inc.
# directly using the email address security@modsecurity.org.

use strict;
use File::Find qw(find);
use File::Spec::Functions qw(catfile);
use Sys::Hostname qw(hostname);
use Digest::MD5 qw(md5_hex);

my $ROOTDIR = $ARGV[0] || '';
my $MLOGC = $ARGV[1] || '';
my $MLOGCCONF = $ARGV[2] || '';
my @AUDIT = ();

if ($ROOTDIR eq '' or ! -e $MLOGC or ! -e $MLOGCCONF) {
	printf STDERR "\nUsage: $0 <rootdir> </path/to/mlogc> <mlogc_config>\n\n";
	exit 1;
}

open(MLOGC, "|$MLOGC -f $MLOGCCONF") or die "ERROR: could not open '$MLOGC' - $!\n";

find(
	{
		wanted => sub {
			my($fn,$dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size);

			(($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size) = stat($_)) &&
			-f _ &&
####        MODSEC-204 /^\d{8}-\d+-\w{24}$/s
            /^\d{8}-\d+-.{24}$/s
			&& (($fn = $File::Find::name) =~ s/^\Q$ROOTDIR\E//)
			&& push(@AUDIT, [$fn, $size]);
		},
		follow => 1,
	},
	$ROOTDIR
);

for my $audit (@AUDIT) {
	my $fn = $audit->[0];
	my $line = "";
	my $err = 0;
	my $ln = 0;
	my $sln = 0;
	my $sect = "";
	my $data = "";
	my %data = (
		hostname => hostname(),
		remote_addr => "-",
		remote_user => "-",
		local_user  => "-",
		logtime => "-",
		request => "-",
		response_status => "-",
		bytes_sent => "-",
		referer => "-",
		user_agent => "-",
		uniqueid => "-",
		sessionid => "-",
		audit_file => $fn,
		extra => "0",
		audit_size => $audit->[1],
		md5 => "-",
	);

	### Parse the audit file in an attempt to recreate the original log line
	open (AUDIT, "<".catfile($ROOTDIR,$fn)) or $err = 1;
	if ($err == 1) {
		print STDERR "ERROR: could not open '$fn' - $!\n";
		next;
	}

	while($line = <AUDIT>) {
		$data .= $line;
		chop $line;
		$ln++;
		$sln++;
		if ($line =~ m%^--[0-9A-Fa-f]{8}-([A-Z])--$%) {
			$sect = $1;
			$sln = 0;
			next;
		};
		if ($sect eq 'A') {
            if ($line =~ m%^(\[[^:]+:\d+:\d+:\d+ [^\]]+\]) (\S+) (\S+) (\d+) (\S+) (\d+)%) {
				$data{logtime} = $1;
				$data{uniqueid} = $2;
				$data{remote_addr} = $3;
			}
			next;
		}
		elsif ($sect eq 'B') {
			if ($sln == 1) {
				$data{request} = $line;
			}
			elsif ($line =~ m%^User=Agent: (.*)%i) {
				$data{user_agent} = $1;
			}
			elsif ($line =~ m%^Referer: (.*)%i) {
				$data{referer} = $1;
			}
			next;
		}
		elsif ($sect eq 'F') {
			if ($sln == 1 and $line =~ m%^\S+ (\d{3})\D?.*%) {
				$data{response_status} = $1;
			}
			elsif ($line =~ m%^Content-Length: (\d+)%i) {
				$data{bytes_sent} = $1;
			}
			next;
		}
	}
	$data{md5} = md5_hex($data);

	printf MLOGC (
		"%s %s %s %s %s \"%s\" %s %s \"%s\" \"%s\" %s \"%s\" %s %s %s md5:%s\n",
		$data{hostname},
		$data{remote_addr},
		$data{remote_user},
		$data{local_user},
		$data{logtime},
		$data{request},
		$data{response_status},
		$data{bytes_sent},
		$data{referer},
		$data{user_agent},
		$data{uniqueid},
		$data{sessionid},
		$data{audit_file},
		$data{extra},
		$data{audit_size},
		$data{md5},
	);
       
}

