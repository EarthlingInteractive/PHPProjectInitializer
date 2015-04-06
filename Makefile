generated_files = vendor/autoload.php templates/PHPTemplateProject
generated_dirs = vendor templates/PHPTemplateProject

default: ${generated_files}

.PHONY: all clean default

clean:
	rm -rf ${generated_files} ${generated_dirs}

all: default

templates/PHPTemplateProject: templates/PHPTemplateProject.version
	rm -rf "$@"
	mkdir -p "$@"
	version=`cat "$<"` && \
	cd "$@" && \
	git init && \
	git remote add github-http https://github.com/EarthlingInteractive/PHPTemplateProject.git && \
	git pull github-http $$version

vendor/autoload.php:
	composer install
	touch "$@"
