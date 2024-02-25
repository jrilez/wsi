# WSI.sh
<ins>W</ins>eb<ins>s</ins>erver <ins>I</ins>nstaller

Simple bash script to install and configure Nginx on Debian. Also configures SSL if elected.

#### Installs:
- nginx

*optional*:
- ufw
- certbot
- python3
  - acme 
  - certbot
  - mock 
  - openssl 
  - pkg-resources 
  - pyparsing 
  - zope.interface
  - certbot-nginx

#### Usage:

`root@web:~# bash wsi.sh [-s email] [-d* site_name] [-u] [-x]`<br />
**\*** *required*

e.g<br />
`root@web:~# bash wsi.sh -s user@example.com -d example.com -u -x`

- -s: use with valid email to enable SSL configuration<br />
      - *email required for certbot*<br />
      - *must have A records configured in DNS provider*
- -d: site name<br />
      *must be valid domain name if SSL enabled*
- -u: enable UFW installation<br />
      *allows port 80 (HTTP), 443 (HTTPS) and 22 (SSH)*
- -x: delete log file<br />
      *if not used, wsi.log is generated in current directory*

#### Outline:


1. Verifies that script was run as root
2. Creates log file if one doesn't exist
3. Checks flags
4. Installs nginx
5. Deletes default nginx files<br />
  \- /var/www/default<br />
  \- /etc/nginx/sites-available/default<br />
  \- /etc/nginx/sites-enabled/default<br />
6. Creates new generic nginx files<br />
  \- /var/www/$site/index.html<br />
  \- /etc/nginx/sites-available/$site<br />
  \- /etc/nginx/sites-enabled/$site<br />
7. Creates *sites-available* to *sites-enabled* symlink
8. Restarts nginx
9. Installs and configures SSL if elected
  \- Installs certbot and python3 dependencies
11. Installs and configures UFW if elected
  \- Opens 22, 80 and 443
12. Deletes log file if elected


#### Etc:
This is really just for my needs, any inevitable security oversights don't apply to me. But please feel free to point them out.
