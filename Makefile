generated_files = vendor/autoload.php templates/PHPTemplateProject
generated_dirs = vendor templates

default: ${generated_files}

.PHONY: all clean default

clean:
	rm -rf ${generated_files} ${generated_dirs}

all: default

templates/PHPTemplateProject:
	mkdir -p "$@"
	cd "$@" && \
	git init && \
	git remote add github-http https://github.com/EarthlingInteractive/PHPTemplateProject.git && \
	git pull github-http 0.3.1

vendor/autoload.php:
	composer install
	touch "$@"
