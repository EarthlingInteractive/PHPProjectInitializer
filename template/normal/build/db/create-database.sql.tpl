CREATE DATABASE {#databaseName};
CREATE USER {#databaseUser} WITH PASSWORD '{#databasePassword}';
GRANT ALL PRIVILEGES ON DATABASE {#databaseName} TO {#databaseUser};
