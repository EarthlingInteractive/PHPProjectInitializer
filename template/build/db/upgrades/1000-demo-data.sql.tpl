INSERT INTO "user"
("id", "username", "passhash", "emailaddress") VALUES
(nextval('entityid'), 'Freddie Mercury', 'blah', 'freddie@mercury.net'),
(nextval('entityid'), 'David Bowie', 'blah', 'david@bowie.net');

INSERT INTO "organization"
("id", "name") VALUES
(nextval('entityid'), 'Queen'),
(nextval('entityid'), 'The Konrads'),
(nextval('entityid'), 'Riot Squad');

INSERT INTO "userorganizationattachment"
("userid", "organizationid") VALUES
(1001, 1003),
(1002, 1004),
(1002, 1005);
