# rsyncster
CMS -> Static site generation using standard \*nix utilities. (Documentation stub)

__Dependencies__
* Bash
* Sudo
* Perl
* Wget
* Rsync
* Sed
* Cron
* Find
* Time

__Backend environment__
* Haproxy (no config support, none planned)
* Nginx (partial config support)
* Apache2 (no config support, none planned)

__Rsyncster Installation__
* Git clone https://github.com/50ten40/rsyncster.git to your $HOME directory. Script assumes $HOME/rsyncster for lib calls.
* No documentation except this file, you'll just have to read the code and comments.
* Usage: Call cron_get_changes.sh from cron entry (see crontab.example in extras). Each script component in main.sh can be called standalone. Pass a domain name or option. There are helper scripts in ./extras.
* NOTE: Configure variables in lib/env.sh.
* NOTE: I update #!/path/to/bash path with symlinks. Eventually I'll get to more portable auto path feature.

__Basic Drupal Workflow__
* Change top level dns record. eg domain.tld -> subdomain.domain.tld
* Update $base_url in settings.php (required)
* Edit site according to CMS assumptions above. eg Strip out everything that is unneccessary.
* Turn off database logging (optional)
* Verify custom logos and favicon. Set in theme and global settings. (optional)
* Update scripts with your subdomain
* Run scripts as needed. Log(s) to /var/log/rsyncster/