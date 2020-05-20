# rsyncster
CMS -> Static site generation using standard \*nix utilities and perl.

Philosophy is seven second rule. Seven seconds total to capture visitors attention. Only two seconds to stop their browsing. Avoid tl;dr. User experience is fast, clean, simple. Mobile optimized. Accessibility is important. Screen reader friendly. Open source, open cloud, 'cause your content is yours and should not be locked to your cloud provider.

This is very basic sloppy code, please vent your frustrations by fixing and sharing your awesome improvements. :)

__Dependencies__
* Bash
* Sudo
* Perl (rsyncster started with perl 20 years ago.)
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