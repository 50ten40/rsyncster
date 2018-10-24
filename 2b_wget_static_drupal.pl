#!/usr/bin/perl
#Usage:
#wget.pl "<URL(s)>" [wait]
die("Please provide one or more URLs.\n") unless ($ARGV[0]);
my $waitTime = 1;
$waitTime = $ARGV[1] if ($ARGV[1]);
chdir('/var/www/html/static_sites') or die "$!";
system("wget -mpk --base=$ARGV[0] --user-agent=\"\" --restrict-file-names=windows -e robots=off --wait $waitTime https://m.$ARGV[0]");
