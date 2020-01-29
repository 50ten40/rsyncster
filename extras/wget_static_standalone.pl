#!/usr/bin/perl
#This script pulls any site into the directory indicated by cli ARGV[1] .
#Usage:
#wget.pl "<URL>" [destination] [wait]

#use URI; #for later

die("Please provide URL or \"all\" to update all static domains.\n") unless ($ARGV[0]);
die("Please provide destination path.\n") unless ($ARGV[1]);

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
my $working_dir = '/var/www/html/.changes'; # Todo: Source from lib/.env.sh
my $manage_dir = '/home/kelley/manage';
my $log_dir = "/var/log/rsyncster";
my $web_user = "kelley";
my $exclude_list = '/admin,/civicrm,/user,/contact';
my $domains_list = "$working_dir/domains.lst";
my $status = "$log_dir/datasync-.changes.status";

if ($ARGV[0] eq "all") { 
	
	open(VIRTUALS, "$manage_dir/virt_domains.list") or die $!; # Todo: Get from nginx/apache sites-enabled
	my @domains = <VIRTUALS>;
	close VIRTUALS;
}

chdir('$ARGV[1]') or die "$!";

foreach (@domains) {

	chomp($_);
	
	#my $uri = URI->new($_); #for later
	#my $host = $uri->host; #for later
	my $host = "$_";
	my ($top_level) = $host =~ m/([^.]+\.[^.]+$)/;
	my $URL = "$scheme"."$load_balancer\.$top_level";
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

		my $dir = "$ARGV[1].$_";
		
		if (-d $dir) {
		
			chdir($dir) or die "$!";
		
		} else {

                	mkdir($dir) or die "$!";
			system("echo \" - TASK : Creating $dir \" >> $status");

		}
		
		my $msg = " - TASK : Fetching files from $host";
                        system("echo \"$msg\" >> $status");

   		system("wget -nH -mpk --base=$host --exclude-directories=$exclude_list --no-check-certificate --user-agent=\"\" --restrict-file-names=windows -e robots=off $waitTime $URL");
		open(DOMS,"+< $domains_list") or die $!;
                        my @doms = <DOMS>;
                        foreach my $line (@doms) {
                                print {DOMS} $line unless (chomp($line) =~ /$_/);
                        }
                close(DOMS);
		system("ls -lah >> $status");

	}

	system("echo $status");
}
