**Web server - db scenario**

Things to continuously check for:

1) Make sure web service is running
2) Check the web app config file for proper connection string to DB (credentials, host,)
3) Make sure web app config is binding to a port/ip 
4) Check the systemd file for the options set

5) Make sure db is running
6) Manually test connection to the db.  If it's refusing, edit pg_hba.conf

reverse proxy:
7) Make sure nginx is running
8) Make sure reverse proxy is configured correctly

SSL:
9) Make sure we run: sudo certbot --nginx --server https://ca.ncaecybergames.org/acme/acme/directory -d team<T>.ncaecybergames.org --no-random-sleep-on-renew
10) Check /etc/letsencrypt/live/team<T>.ncaecybergames.org/ for cert files.
11) Check the nginx SSL config to make sure its pointing to them

ssl_certificate /etc/letsencrypt/live/team<T>.ncaecybergames.org/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/team<T>.ncaecybergames.org/privkey.pem;

Web content:
12) Make sure connection from web server and db are working and ports are open. Edit firewall if needed
13) Make sure web scoring user can login

Other:
14) Make sure connections from the router for port 80 and 443 are forwarded to the web server
15) Certbot will automatically use the correct Root CA, so as long as you generate the certificate via that server, you don't need to manually worry about the hash

to verify:
openssl x509 -noout -hash -in root_ca_certificate.pem



Other hints:

- Check for any disabled or misconfigured default settings that are "super secure"
- Look for security headers (such as X-Frame-Options, X-XSS-Protection, Strict-Transport-Security, etc.) in the configuration of the reverse proxy (if using Nginx or Apache) and the Flask app.
- Check if SSL is being used throughout the app (including database connections)
- Ensure that there are no open ports or unnecessary services exposed to the internet.
- ensure that the database connection is secured (e.g., using SSL/TLS between the Flask app and the PostgreSQL database, and ensuring proper database user access rights)


