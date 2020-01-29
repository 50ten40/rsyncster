#!/usr/bin/perl
#This script pulls any site into the directory indicated by cli ARGV[1] .
#Usage:
#wget.pl "<URL>" <destination>

#use URI; #for later

die("Please provide URL. Usage: URL full-path-to-destination\n") unless ($ARGV[0]);
die("Please provide destination path. Usage: URL full-path-to-destination\n") unless ($ARGV[1]);

my $scheme = "https://";
my @domains = $ARGV[0];
my $log_dir = "$ARGV[1]";
my $status = "$log_dir/$ARGV[0]_puller.status";



chdir('$ARGV[1]') or die "$!";

foreach (@domains) {

	chomp($_);
	
	my $host = "$_";
	my ($top_level) = $host =~ m/([^.]+\.[^.]+$)/;
	my $URL = "$scheme"."$load_balancer\.$top_level";

	my $dir = "$_";
		
	if (-d $dir) {
		
		chdir($dir) or die "$!";
		
	} else {

	       	mkdir($dir) or die "$!";
		system("echo \" - TASK : Creating $dir \" >> $status");
		chdir($dir) or die "$!";

	}
		
	my $msg = " - TASK : Fetching files from $host";
        system("echo \"$msg\" >> $status");
   	system("wget -nH -mpk --base=$host --exclude-directories=$exclude_list --no-check-certificate --user-agent=\"\" --restrict-file-names=windows -e robots=off $URL");
	system("ls -lah >> $status");
	system("cat $status");
}
