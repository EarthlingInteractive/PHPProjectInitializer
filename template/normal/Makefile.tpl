generated_files = \
	build/db/upgrades/0110-create-tables.sql \
	build/db/upgrades/0097-drop-tables.sql \
	util/SchemaSchemaDemo.jar \
	util/{#databaseName}-psql \
	schema/schema.php

run_schema_processor = \
	java -jar util/SchemaSchemaDemo.jar \
	-o-create-tables-script build/db/upgrades/0110-create-tables.sql \
	-o-drop-tables-script build/db/upgrades/0097-drop-tables.sql \
	-o-schema-php schema/schema.php -php-schema-class-namespace EarthIT_Schema \
	schema/schema.txt

all: ${generated_files}

clean:
	rm -f ${generated_files}

.DELETE_ON_ERROR:

.PHONY: \
	all \
	rebuild-database \
	run-service-tests \
	clean

util/{#databaseName}-psql: config/dbc.json
	util/generate-psql-script >$@
	chmod +x $@

util/SchemaSchemaDemo.jar: util/SchemaSchemaDemo.jar.urn
	rm -f $@
	# TODO: Use some other server(s)
	curl -o $@ 'http://pvps1.nuke24.net/uri-res/N2R?'`cat "$<"`

build/db/upgrades/0110-create-tables.sql: schema/schema.txt util/SchemaSchemaDemo.jar
	${run_schema_processor}

build/db/upgrades/0097-drop-tables.sql: schema/schema.txt util/SchemaSchemaDemo.jar
	${run_schema_processor}

schema/schema.php: schema/schema.txt util/SchemaSchemaDemo.jar
	${run_schema_processor}

rebuild-database: ${generated_files}
	cat build/db/upgrades/*.sql | util/{#databaseName}-psql -q

run-service-tests:
	${MAKE} -C service-tests
