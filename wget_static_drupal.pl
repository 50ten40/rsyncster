#!/usr/bin/perl
#Usage:
#wget.pl "<URL(s)>" [wait]

die("Please provide URL or \"all\" to update all static domains.\n") unless ($ARGV[0]);
#$waitTime = $ARGV[1] if ($ARGV[1]);
my $waitTime = 1;
my $prefix = "https://m";
my @domains = $ARGV[0]; # Todo: Use changed files list at limit wget. For now, refresh site.

if($ARGV[0] eq "all") { 
	
	open(VIRTUALS, "virt_domains.list") or die $!;
	my @domains = <VIRTUALS>;
	close VIRTUALS;
}

chdir('/var/www/html/staging') or die "$!";

foreach (@domains) {
	chomp($_);
   	system("wget -mpk --base=$_ --user-agent=\"\" --restrict-file-names=windows -e robots=off --wait $waitTime $prefix.$_");
	system("chown -R kelley.kelley m.$_");
}
