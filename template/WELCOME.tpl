[36m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Woohoo! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~[39m

You've set up {#projectName}!

If you haven't already, you can set up a new postgres database by
logging in as root and running:

[34m  CREATE DATABASE {#databaseName};
  CREATE USER {#databaseUser} WITH PASSWORD '{#databasePassword}';
  GRANT ALL PRIVILEGES ON DATABASE {#databaseName} TO {#databaseUser};[0m

Then at the command prompt from within your project directory, type:

[34m  make rebuild-database[0m

Happy hacking!
[36m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~[39m
