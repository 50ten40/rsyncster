# rsyncster
CMS -> Static site generation using standard \*nix utilities.

Philosophy is seven second rule. Avoid tl;dr. User experience is fast, clean, simple. Mobile optimized. Accessibility is important. Screen reader friendly. Open source, open cloud, 'cause your content is yours and should not be locked to your cloud provider.

This is very basic sloppy code, please vent your frustrations by fixing and sharing your awesome improvements. :)

Dependencies
* Perl
* Wget
* Rsync
* Sed
* Cron

Backend environment 
* Haproxy
* Nginx
* Apache2

CMS assumptions
* Simplified one-page interface. Bootstrap theme.
* Mobile emphasis. No menus, mobile users can't see, don't use.
* No ajax or sliding features etc.
* Deep functionality and ui complexity available with login.
* Public facing assets are obsessively lean and easily consumed.

Basic Drupal Workflow
* Change top level dns record. eg domain.tld -> subdomain.domain.tld
* Update $base_url in settings.php (required)
* Edit site according to CMS assumptions above. eg Strip out everything that is unneccessary.
* Enable anonymous page caching (required)
* Turn off database logging (optional)
* Verify custom logos and favicon. Set in theme and global settings.(optional)
* Update scripts with your subdomain
* Run scripts as needed
* Enjoy your new peace of mind.
