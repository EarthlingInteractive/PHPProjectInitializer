[36m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Woohoo! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~[39m

You've set up {#projectName}!

On most Ubuntu-like systems you should be able to create the database
for your project by entering the project directory and running:

[34m  make create-database[0m

If that doesn't work, try running the following SQL as the root
database user:

[34m  CREATE DATABASE {#databaseName};
  CREATE USER {#databaseUser} WITH PASSWORD '{#databasePassword}';
  GRANT ALL PRIVILEGES ON DATABASE {#databaseName} TO {#databaseUser};[0m

To initialize the contents of the database from the scripts in
build/db/upgrades, run:

[34m  make rebuild-database[0m

This information is also in README.md.

Happy hacking!
[36m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~[39m
