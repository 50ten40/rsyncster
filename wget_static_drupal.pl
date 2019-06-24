#!/usr/bin/perl
#Usage:
#wget.pl "<URL(s)>" [wait]

die("Please provide URL or \"all\" to update all static domains.\n") unless ($ARGV[0]);

if ($ARG[2]) {
	my $waitTime = "--wait $ARGV[2]"; 
} else { 
	my $waitTime = "";
}

my $scheme = "https://";
my $load_balancer = "lbint";
my $sub_domain = "m";
my $prefix = "$scheme"."$load_balancer";
my @domains = $ARGV[0];
my $working_dir = '/var/www/html/.changes'; # Todo: Source from lib
my $manage_dir = '/home/kelley/manage';
my $log_dir = "/var/log/rsyncster";
my $web_user = "kelley";
my $exclude_list = '/admin,/civicrm';
my $domains_list = "$working_dir/domains.lst";
my $status = "$log_dir/datasync-.changes.status";

if ($ARGV[0] eq "all") { 
	
	open(VIRTUALS, "$manage_dir/virt_domains.list") or die $!; # Todo: Get from nginx/apache sites-enabled
	my @domains = <VIRTUALS>;
	close VIRTUALS;
}

chdir('/var/www/html/staging') or die "$!";

foreach (@domains) {

	chomp($_);
	
	my $host = "$_";
	my $URL = "$scheme"."$load_balancer\.$host";
	my $listicle = "$working_dir/$_\.$sub_domain\.$_";
	
	if (-s $listicle > 3) {
			
		my $dir = "$sub_domain\.$_";
		chdir($dir) or die "$!";
		
		open(PAGES, $listicle) or die $!;
		my @pages = <PAGES>;
		close(PAGES);

		foreach (@pages) {
			
			chomp($_);
			
			my $msg = " - TASK : Fetching $_";
                        system("echo \"$msg\" >> $status");

			my $target = "$_";
			system("wget -x -nH -mpk --base=$host -l 1 --exclude-directories=$exclude_list --no-check-certificate --user-agent=\"\" --restrict-file-names=windows -e robots=off $waitTime $target");
			
			my $msg = " - TASK : Fetch completed for $_";
                        system("echo \"$msg\" >> $status");
	
			open(PAGES,"+< $listicle") or die $!;
                	my @pages = <PAGES>;
			foreach my $line (@pages) { 
        			print {PAGES} $line unless (chomp($line) =~ /$_/); 
    			}
			close(PAGES);

			my $msg = " - TASK : Removed listicle entry $_";
                        system("echo \"$msg\" >> $status");			
		
		}
		
		if (-z $listicle) {
			unlink($listicle);
		}


		#my $msg = " - TASK : Unlinking changes file for $_";
                #system("echo \"$msg\" >> $status");
		
	} else {

		my $dir = "$sub_domain\.$_";
                chdir($dir) or die "$!";
		
		my $msg = " - TASK : Fetching files from $host";
                        system("echo \"$msg\" >> $status");

   		system("wget -nH -mpk --base=$host --exclude-directories=$exclude_list --no-check-certificate --user-agent=\"\" --restrict-file-names=windows -e robots=off $waitTime $URL");
		open(DOMS,"+< $domains_list") or die $!;
                        my @doms = <DOMS>;
                        foreach my $line (@doms) {
                                print {DOMS} $line unless (chomp($line) =~ /$_/);
                        }
                close(DOMS);

	}

	chdir('/var/www/html/staging') or die "$!";
	system("chown -R $web_user.$web_user $sub_domain\.$host");
}
