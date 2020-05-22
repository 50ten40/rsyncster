#!/usr/bin/perl
#Usage:
#wget.pl "<URL(s)>" [wait]

#use URI; #for later

die("Please provide URL or \"all\" to update all static domains.\n") unless ($ARGV[0]);

#use strict;

# Get source from lib/env.sh
use Env::Modify 'source', ':bash';
my $result = source("$ENV{HOME}/rsyncster/lib/env.sh");

if ($ENV{DEBUG} eq "yes") {

	my $msg = " - TEST : Result of source cmd is $result";
	system("echo \"$msg\" >> $ENV{status}");
	my $msg = " - TEST : Status destination is $ENV{status}";
	system("echo \"$msg\" >> $ENV{status}");

}

# Get wait time 
if ($ARG[2]) {

	my $waitTime = "--wait $ARGV[2]";

} else {

	my $waitTime = "--wait $ENV{waittime}";
}

my $scheme = $ENV{SCHEME};
my $lb = $ENV{LOADBALANCER};
my $sub_domain = $ENV{PREFIX};
my $prefix = "$scheme"."$lb";
my @domains = $ARGV[0];
my $working_dir = $ENV{WORKINGDIR};
my $manage_dir = $ENV{HOME};
my $staging_dir = $ENV{STAGINGDIR};
my $log_dir = $ENV{LOGDIR};
my $web_user = $ENV{WEBUSER};
my $exclude_list = $ENV{exclusions};
my $domains_list = $ENV{DOMAINSFILE};
my $status_file = $ENV{status};
my $waitTime = "";

if ($ARGV[0] eq "all") { # Not in use currently. Get from live server via get_drupal_files function. Manage dir deprecated.
	
	open(VIRTUALS, "$manage_dir/virt_domains.list") or die $!;
	my @domains = <VIRTUALS>;
	close VIRTUALS;
}

if ($ENV{DEBUG} eq "yes") {

	my $msg = " - TEST : Perl env for staging directory set to $staging_dir";
	system("echo \"$msg\" >> $status_file");

}

unless (-d $staging_dir) {
      mkdir $staging_dir or die "$!";
}

chdir($staging_dir) or die "$!";

foreach (@domains) {

	chomp($_);
	
	#my $uri = URI->new($_); #for later
	#my $host = $uri->host; #for later
	my $host = "$_";
	my ($top_level) = $host =~ m/([^.]+\.[^.]+$)/;
	my $URL = "$scheme"."$lb\.$top_level";
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
                        system("echo \"$msg\" >> $status_file");

			my $target = "$_";
			system("/usr/local/bin/wget -x -nH -mpk --base=$host -l 1 --exclude-directories=$exclude_list --no-check-certificate --user-agent=\"\" --restrict-file-names=windows -e robots=off $waitTime $target");
			
			my $msg = " - TASK : Fetch completed for $_";
                        system("echo \"$msg\" >> $status_file");
	
			open(PAGES,"+< $listicle") or die $!;
                	my @pages = <PAGES>;
			foreach my $line (@pages) { 
        			print {PAGES} $line unless (chomp($line) =~ /$_/); 
    			}
			close(PAGES);

			my $msg = " - TASK : Removed listicle entry $_";
                        system("echo \"$msg\" >> $status_file");			
		
		}
		
		if (-z $listicle) {
			unlink($listicle);
		}


		#my $msg = " - TASK : Unlinking changes file for $_";
                #system("echo \"$msg\" >> $status_file");
		
	} else {

		my $dir = "$sub_domain\.$_";
		
		if (-d $dir) {
		
			chdir($dir) or die "$!";
		
		} else {

                	mkdir($dir) or die "$!";
			system("echo \" - TASK : Creating $dir \" >> $status_file");

		}
		
		my $msg = " - TASK : Fetching files from $host";
                        system("echo \"$msg\" >> $status_file");

   		system("/usr/local/bin/wget -nH -mpk --base=$host --exclude-directories=$exclude_list --no-check-certificate --user-agent=\"\" --restrict-file-names=windows -e robots=off $waitTime $URL");
		open(DOMS,"+< $domains_list") or die $!;
                        my @doms = <DOMS>;
                        foreach my $line (@doms) {
                                print {DOMS} $line unless (chomp($line) =~ /$_/);
                        }
                close(DOMS);

	}

	chdir($staging_dir) or die "$!";
	my $msg = " - TASK : Setting web user to $web_user";
	system("echo \"$msg\" >> $status_file");
	system("chown -R $web_user $sub_domain\.$host");
	my $msg = " - TASK : Setting web group to $web_user";
        system("echo \"$msg\" >> $status_file");
	system("chgrp -R $web_user $sub_domain\.$host");
}
