generated_files = vendor templates/PHPTemplateProject

default: ${generated_files}

.PHONY: all clean default

clean:
	rm -rf ${generated_files}

all: default

templates/PHPTemplateProject: templates/PHPTemplateProject.version
	rm -rf "$@"
	mkdir -p "$@"
	version=`cat "$<"` && \
	cd "$@" && \
	git init && \
	git remote add github-http https://github.com/EarthlingInteractive/PHPTemplateProject.git && \
	git pull github-http $$version

vendor: composer.lock
	composer install
	touch "$@"

composer.lock: | composer.json
	rm -f "$@"
	composer install
