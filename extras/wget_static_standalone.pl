#!/usr/bin/perl
#This script pulls any site into the directory indicated by cli ARGV[1] .
#Usage: wget.pl <URL> <destination>

die("Please provide URL. Usage: URL full-path-to-destination\n") unless ($ARGV[0]);
die("Please provide destination path. Usage: URL full-path-to-destination\n") unless ($ARGV[1]);

my $scheme = "https://";
my @domains = "$ARGV[0]";
my $log_dir = "$ARGV[1]";


chdir("$ARGV[1]") or die "$!";

foreach (@domains) {

	chomp($_);
	
	my $host = "$_";
	my $URL = "$scheme"."$host";

	my $dir = "$_";
		
	if (-d $dir) {
		
		chdir($dir) or die "$!";
		
	} else {

	       	mkdir($dir) or die "$!";
		system("echo \" - TASK : Creating $dir \"");
		chdir($dir) or die "$!";

	}
		
	my $msg = "\n======== TASK : Fetching files from $host ========\n";
        system("echo \"$msg\"");
   	system("wget -nH -mpk --base=$host --exclude-directories=$exclude_list --no-check-certificate --user-agent=\"\" --restrict-file-names=windows -e robots=off $URL");

	system("echo \"\n======== NOTICE : Begin $dir listing ========\n\"");
	system("ls -lah");
	system("echo \"\n======== NOTICE : End $dir listing ========\n\"");
}
