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
* Haproxy (no config support, none planned )
* Nginx ( partial config support )
* Apache2 ( no config support, none planned )

__CMS assumptions__
* Simplified responsive user experience.
* Mobile emphasis.
* Deep cms functionality available only with login.
* Public facing assets are plain html and javascript.
* Sites are lean and easily consumed on small screens.