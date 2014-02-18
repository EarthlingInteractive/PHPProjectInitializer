~~~~~~~~~~ Woohoo! ~~~~~~~~~~

You've set up {#projectName}!

If you haven't already, you can set up a new postgres database by
logging in as root and running:

  CREATE DATABASE {#databaseName};
  CREATE USER {#databaseUser} WITH PASSWORD '{#databasePassword}';
  GRANT ALL PRIVILEGES ON DATABASE {#databaseName} TO {#databaseUser};

Then at the command prompt from within your project directory, type:

  make rebuild-database

Happy hacking!
