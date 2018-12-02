#!/usr/bin/perl
#Usage:
#wget.pl "<URL(s)>" [wait]

die("Please provide URL or \"all\" to update all static domains.\n") unless ($ARGV[0]);
#$waitTime = $ARGV[1] if ($ARGV[1]);
my $waitTime = 1;
my $prefix = "https://m";
my @domains = $ARGV[0];
my $working_dir = '/var/www/html/.changes'; # Todo: Source from lib
my $manage_dir = '/home/kelley/manage';
my $log_dir = "/var/log/rsyncster";
my $status = "$log_dir/datasync-.changes.status";

if ($ARGV[0] eq "all") { 
	
	open(VIRTUALS, "$manage_dir/virt_domains.list") or die $!; # Todo: Get from nginx/apache sites-enabled
	my @domains = <VIRTUALS>;
	close VIRTUALS;
}

chdir('/var/www/html/staging') or die "$!";

foreach (@domains) {

	chomp($_);
	
	my $base = "$_";
	my $listicle = "$working_dir/$_/m\.$_";
	
	if (-e $listicle) {
			
		my $dir = "m\.$_";
		chdir($dir) or die "$!";
		
		open(PAGES, $listicle) or die $!;
		my @pages = <PAGES>;
		close(PAGES);

		foreach (@pages) {
			
			chomp($_);
			
			my $msg = " - TASK : Processing started for $_";
                        system("echo \"$msg\" >> $status");

			my $target = "$_";
			system("wget -x -nH -mpk --base=$base --user-agent=\"\" --restrict-file-names=windows -e robots=off --wait $waitTime $target");

			my $msg = " - TASK : Processing completed for $_";
			system("echo \"$msg\" >> $status");
		}
		
		unlink($listicle);
		
		my $msg = " - TASK : Unlinking changes file for $_";
                system("echo \"$msg\" >> $status");
		
	} else {

   		system("wget -mpk --base=$base --user-agent=\"\" --restrict-file-names=windows -e robots=off --wait $waitTime $prefix.$_");
	}	

	chdir('/var/www/html/staging') or die "$!";
	system("chown -R kelley.kelley m.$_");
}
