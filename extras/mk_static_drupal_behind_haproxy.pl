#!/usr/bin/perl -w
# run from linux server todo: autoupdate *bsd path

use DateTime qw();
my $nowstring =	DateTime->now->strftime('%d%b%Y');
my $config_dir = '/etc/nginx/sites-available/';
open(VIRTUALS, "virt_domains.list") or die $!;
my @domains = <VIRTUALS>;

foreach (@domains) { 
   chomp($_);

   my $config_filename = "static.$_.conf";
   my $config_path = $config_dir.$config_filename;
   
   my $string = "# Generated automagically on $nowstring. \n\n";
   $string .= "server \{\n\n";
   $string .= "        listen       80;\n";
   $string .= "        listen       [::]:80;\n";
   $string .= "        server_name  www.$_;\n";
   $string .= "        rewrite ^    https://$_\$request_uri? permanent;\n";
   $string .= "\}\n\n";
   $string .= "server \{\n\n";
   $string .= "        listen       80;\n";
   $string .= "        listen       [::]:80;\n";
   $string .= "        server_name  $_;\n";  
   $string .= "        root /var/www/html/live/m.$_; ## <-- Your only path reference.\n";
   $string .= "        include snippets/rsyncster_static_sites.conf;\n";
   $string .= "\}\n";

   open(STATIC_CONFIG, ">", $config_path) or die $!;
   print STATIC_CONFIG $string;
   close STATIC_CONFIG;

   my $db2_config_filename = "db2.static.$_.conf";
   my $db2_config_path = $config_dir.$db2_config_filename;

   my $db2_string = "# Generated automagically on $nowstring. \n\n";
   $db2_string .= "server \{\n\n";
   $db2_string .= "        listen       127.0.0.1:80;\n";
   $db2_string .= "        listen       [::1]:80;\n";
   $db2_string .= "        server_name  www.$_;\n";
   $db2_string .= "        rewrite ^    https://$_\$request_uri? permanent;\n";
   $db2_string .= "\}\n\n";
   $db2_string .= "server \{\n\n";
   $db2_string .= "        listen       127.0.0.1:80;\n";
   $db2_string .= "        listen       [::1]:80;\n";
   $db2_string .= "        server_name  $_;\n";
   $db2_string .= "        root /var/www/html/live/m.$_; ## <-- Your only path reference.\n";
   $db2_string .= "        include snippets/rsyncster_static_sites.conf;\n";";
   $db2_string .= "\}\n";

   close VIRTUALS;

   open(db2_STATIC_CONFIG, ">", $db2_config_path) or die $!;
   print db2_STATIC_CONFIG $db2_string;
   close db2_STATIC_CONFIG;

}
