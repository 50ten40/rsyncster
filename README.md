# rsyncster
CMS -> Static site generation using standard \*nix utilities.

Philosophy is seven second rule. Seven seconds total to capture visitors attention. Only two seconds to stop their browsing. Avoid tl;dr. User experience is fast, clean, simple. Mobile optimized. Accessibility is important. Screen reader friendly. Open source, open cloud, 'cause your content is yours and should not be locked to your cloud provider.

This is very basic sloppy code, please vent your frustrations by fixing and sharing your awesome improvements. :)

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
* Haproxy
* Nginx ( partial config support )
* Apache2 ( no config support )

__CMS assumptions__
* Simplified interface. Assumed Bootstrap theme.
* Mobile emphasis..
* Deep functionality available only with login.
* Public facing assets are obsessively lean and easily consumed.

__Rsyncster Installation__
* Git clone https://github.com/50ten40/rsyncster.git to your management directory.
* No documentation, you'll just have to read the code.
* Usage: Call cron\_get\_changes.sh from cron entry. Each script component in main.sh can be called standalone. Pass a domain name or option. There are helper scripts in ./extras.
* Configure variables for your setup.

__Basic Drupal Workflow__
* Change top level dns record. eg domain.tld -> subdomain.domain.tld do not use for public access. Haproxy :). Read code for rationale.
* Update $base_url in settings.php (required)
* Edit site according to CMS assumptions above. eg Strip out everything that is unneccessary.
* Disable page caching ( required, your site is static, don't need drupal caching )
* Turn off database logging ( optional )
* Verify custom logos and favicon. Set in theme and global settings.( optional )
* Update scripts with your subdomain
* Run scripts as needed
* Enjoy!
