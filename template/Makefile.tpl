generated_files = \
	build/db/upgrades/0110-create-tables.sql \
	build/db/upgrades/0097-drop-tables.sql \
	schema/schema.php

all: ${generated_files}

clean:
	rm -f ${generated_files}

run_schema_processor = \
	java -jar util/SchemaSchemaDemo.jar \
	-o-create-tables-script build/db/upgrades/0110-create-tables.sql \
	-o-drop-tables-script build/db/upgrades/0097-drop-tables.sql \
	-o-schema-php schema/schema.php -php-schema-class-namespace EarthIT_Schema \
	schema/schema.txt

util/SchemaSchemaDemo.jar: Makefile
	# TODO: Use some other server(s)
	curl -o $@ 'http://pvps1.nuke24.net/uri-res/N2R?urn:bitprint:4V3CDFEIA4J7WI3Y4NOJGKGZPNCKP3E6.T2GEMT4AQ2LLDRPYWXEHUPNONRIMEIOH7RNMNAQ'

build/db/upgrades/0110-create-tables.sql: schema/schema.txt util/SchemaSchemaDemo.jar
	${run_schema_processor}

build/db/upgrades/0097-drop-tables.sql: schema/schema.txt util/SchemaSchemaDemo.jar
	${run_schema_processor}

schema/schema.php: schema/schema.txt util/SchemaSchemaDemo.jar
	${run_schema_processor}

rebuild-database: ${generated_files}
	cat build/db/upgrades/*.sql | util/{#databaseName}-psql
